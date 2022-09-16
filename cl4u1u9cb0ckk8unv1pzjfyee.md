## Configmap/Secret Manager

<a name="YjhpG"></a>
## ReadLink

- [configmap manager](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/blob/pkg/kubelet/configmap/configmap_manager.go)
- [pkg/kubelet/secret/secret_manager.go](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/blob/pkg/kubelet/secret/secret_manager.go)
<a name="GuGtv"></a>

## Configmap Manager

```go
// Manager interface provides methods for Kubelet to manage ConfigMap.
type Manager interface {
    // Get configmap by configmap namespace and name.
    GetConfigMap(namespace, name string) (*v1.ConfigMap, error)
    
    // WARNING: Register/UnregisterPod functions should be efficient,
    // i.e. should not block on network operations.
    
    // RegisterPod registers all configmaps from a given pod.
    RegisterPod(pod *v1.Pod)
    
    // UnregisterPod unregisters configmaps from a given pod that are not
    // used by any other registered pod.
    UnregisterPod(pod *v1.Pod)
}
```

接口非常简单。

1. GetConfigMap ： 通过 namespace 和 name 获取对应 ConfigMap 对象。
1. RegisterPod(pod *v1.Pod)：把指定 Pod 对象 yaml 指定的 configmap 注册到 Controller 中管理
1. UnregisterPod(pod *v1.Pod)：把指定 Pod 对象 yaml 指定的 configmap 从 Controller 中注册管理中删除，注意 ConfigMap 需要没有任何其他已注册的 Pod 引用（即无被依赖项）才可以删除

当前代码中有两种 manager 的实现

-`NewCachingConfigMapManager(kubeClient clientset.Interface, getTTL manager.GetObjectTTLFunc) Manager`：该实现有两点逻辑
   - 当一个 Pod 创建或者更新时，所有的 configmap 缓存都失效。
   -  GetObject() 调用首先从本地缓存获取，失败则访问 APISever 并刷新 configmap 的缓存。

```go
// NewCachingConfigMapManager creates a manager that keeps a cache of all configmaps
// necessary for registered pods.
// It implement the following logic:
// - whenever a pod is create or updated, the cached versions of all configmaps
//   are invalidated
// - every GetObject() call tries to fetch the value from local cache; if it is
//   not there, invalidated or too old, we fetch it from apiserver and refresh the
//   value in cache; otherwise it is just fetched from cache
func NewCachingConfigMapManager(kubeClient clientset.Interface, getTTL manager.GetObjectTTLFunc) Manager {
	getConfigMap := func(namespace, name string, opts metav1.GetOptions) (runtime.Object, error) {
		return kubeClient.CoreV1().ConfigMaps(namespace).Get(context.TODO(), name, opts)
	}
	configMapStore := manager.NewObjectStore(getConfigMap, clock.RealClock{}, getTTL, defaultTTL)
	return &configMapManager{
		manager: manager.NewCacheBasedManager(configMapStore, getConfigMapNames),
	}
}
```

- `NewWatchingConfigMapManager(kubeClient clientset.Interface, resyncInterval time.Duration) Manager`：
   - 当一个 Pod 创建或者更新时，会对指定该 Pod 引用的资源，并且该资源未被其他 Pod 引用进行独立的 watch。
   - GetObject() 调用首先从本地缓存获取

```go
// NewWatchingConfigMapManager creates a manager that keeps a cache of all configmaps
// necessary for registered pods.
// It implements the following logic:
// - whenever a pod is created or updated, we start individual watches for all
//   referenced objects that aren't referenced from other registered pods
// - every GetObject() returns a value from local cache propagated via watches
func NewWatchingConfigMapManager(kubeClient clientset.Interface, resyncInterval time.Duration) Manager {
	listConfigMap := func(namespace string, opts metav1.ListOptions) (runtime.Object, error) {
		return kubeClient.CoreV1().ConfigMaps(namespace).List(context.TODO(), opts)
	}
	watchConfigMap := func(namespace string, opts metav1.ListOptions) (watch.Interface, error) {
		return kubeClient.CoreV1().ConfigMaps(namespace).Watch(context.TODO(), opts)
	}
	newConfigMap := func() runtime.Object {
		return &v1.ConfigMap{}
	}
	isImmutable := func(object runtime.Object) bool {
		if configMap, ok := object.(*v1.ConfigMap); ok {
			return configMap.Immutable != nil && *configMap.Immutable
		}
		return false
	}
	gr := corev1.Resource("configmap")
	return &configMapManager{
		manager: manager.NewWatchBasedManager(listConfigMap, watchConfigMap, newConfigMap, isImmutable, gr, resyncInterval, getConfigMapNames),
	}
}

```

<a name="gEtqm"></a>
## Secret Manager

secret manager 除了资源类型和 configmap 不一样，其他逻辑相同，所以仅列出两种 secret manager 的初始化函数。<br />[/](https://sourcegraph.com/github.com/kubernetes/kubernetes)[pkg /](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/tree/pkg)[kubelet /](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/tree/pkg/kubelet)[secret /](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/tree/pkg/kubelet/secret)[secret_manager.go](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/blob/pkg/kubelet/secret/secret_manager.go)

```go
// NewCachingSecretManager creates a manager that keeps a cache of all secrets
// necessary for registered pods.
// It implements the following logic:
// - whenever a pod is created or updated, the cached versions of all secrets
//   are invalidated
// - every GetObject() call tries to fetch the value from local cache; if it is
//   not there, invalidated or too old, we fetch it from apiserver and refresh the
//   value in cache; otherwise it is just fetched from cache
func NewCachingSecretManager(kubeClient clientset.Interface, getTTL manager.GetObjectTTLFunc) Manager {
	getSecret := func(namespace, name string, opts metav1.GetOptions) (runtime.Object, error) {
		return kubeClient.CoreV1().Secrets(namespace).Get(context.TODO(), name, opts)
	}
	secretStore := manager.NewObjectStore(getSecret, clock.RealClock{}, getTTL, defaultTTL)
	return &secretManager{
		manager: manager.NewCacheBasedManager(secretStore, getSecretNames),
	}
}

// NewWatchingSecretManager creates a manager that keeps a cache of all secrets
// necessary for registered pods.
// It implements the following logic:
// - whenever a pod is created or updated, we start individual watches for all
//   referenced objects that aren't referenced from other registered pods
// - every GetObject() returns a value from local cache propagated via watches
func NewWatchingSecretManager(kubeClient clientset.Interface, resyncInterval time.Duration) Manager {
	listSecret := func(namespace string, opts metav1.ListOptions) (runtime.Object, error) {
		return kubeClient.CoreV1().Secrets(namespace).List(context.TODO(), opts)
	}
	watchSecret := func(namespace string, opts metav1.ListOptions) (watch.Interface, error) {
		return kubeClient.CoreV1().Secrets(namespace).Watch(context.TODO(), opts)
	}
	newSecret := func() runtime.Object {
		return &v1.Secret{}
	}
	isImmutable := func(object runtime.Object) bool {
		if secret, ok := object.(*v1.Secret); ok {
			return secret.Immutable != nil && *secret.Immutable
		}
		return false
	}
	gr := corev1.Resource("secret")
	return &secretManager{
		manager: manager.NewWatchBasedManager(listSecret, watchSecret, newSecret, isImmutable, gr, resyncInterval, getSecretNames),
	}
}
```

<a name="RX3SN"></a>
## cache_based_manager
[/](https://sourcegraph.com/github.com/kubernetes/kubernetes)[pkg /](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/tree/pkg)[kubelet /](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/tree/pkg/kubelet)[util /](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/tree/pkg/kubelet/util)[manager /](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/tree/pkg/kubelet/util/manager)[cache_based_manager.go](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/blob/pkg/kubelet/util/manager/cache_based_manager.go)

```go
// cacheBasedManager keeps a store with objects necessary
// for registered pods. Different implementations of the store
// may result in different semantics for freshness of objects
// (e.g. ttl-based implementation vs watch-based implementation).
type cacheBasedManager struct {
    objectStore          Store
	getReferencedObjects func(*v1.Pod) sets.String

	lock           sync.Mutex
	registeredPods map[objectKey]*v1.Pod
}
```

该 manager 代码位于  [/](https://sourcegraph.com/github.com/kubernetes/kubernetes)[pkg /](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/tree/pkg)[kubelet /](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/tree/pkg/kubelet)[util /](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/tree/pkg/kubelet/util)[manager /](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/tree/pkg/kubelet/util/manager)[cache_based_manager.go](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/blob/pkg/kubelet/util/manager/cache_based_manager.go)，属于通用的 Manager 结构体工具，用于保留注册的  Pod 所必要引用的 kubernetes 对象（objects）<br />如何做到的呢？<br />通过 getReferencedObjects 字段，一个可以传入的成员函数，自定义实现用于从 v1.Pod 对象中获取到对应对象（或一组对象）的 name。流程如下：

```go
func (c *cacheBasedManager) RegisterPod(pod *v1.Pod) {
    // 1. 获取名字
	names := c.getReferencedObjects(pod)
	c.lock.Lock()
	defer c.lock.Unlock()
    // 2. 给每一个名字和 pod 的命名空间一起添加到 c.objectStore 中存储
	for name := range names {
		c.objectStore.AddReference(pod.Namespace, name)
	}
    // 3. 检查是否之前已经注册了该 Pod
	var prev *v1.Pod
	key := objectKey{namespace: pod.Namespace, name: pod.Name, uid: pod.UID}
	prev = c.registeredPods[key]
    // 4. 用新注册的 pod 替换之前存储的注册 Pod 的信息.
	c.registeredPods[key] = pod
    // 5. 删除旧 Pod 在 c.objectStore 中的引用信息,这是因为在上面第二步 Add 到 c.objectStore
    // 中时,这些资源的引用次数又新增了一次,但实际上只是同一个 Pod 的引用,自然需要删除,当然,也有
    // 可能新 Pod 已经不再引用目标资源了, Delete 函数在下面也处理这个情况
	if prev != nil {
		for name := range c.getReferencedObjects(prev) {
			// On an update, the .Add() call above will have re-incremented the
			// ref count of any existing object, so any objects that are in both
			// names and prev need to have their ref counts decremented. Any that
			// are only in prev need to be completely removed. This unconditional
			// call takes care of both cases.
			c.objectStore.DeleteReference(prev.Namespace, name)
		}
	}
}
```

1. 获取名字
1. 给每一个名字和 pod 的命名空间一起添加到 c.objectStore 中存储
1. 检查是否之前已经注册了该 Pod
1. 用新注册的 pod 替换之前存储的注册 Pod 的信息.
5. 删除旧 Pod 在 c.objectStore 中的引用信息,这是因为在上面第二步 Add 到 c.objectStore 中时,这些资源的引用次数又新增了一次,但实际上只是同一个 Pod 的引用,自然需要删除,当然,也有可能新 Pod 已经不再引用目标资源了, Delete 函数在下面也处理这个情况

<a name="aQgQM"></a>
### ttl ObjectStore

cache_based 的 objectStore 通过 ttl 设置缓存有效期。
<a name="qzaxL"></a>

## watch_based_manager
[/](https://sourcegraph.com/github.com/kubernetes/kubernetes)[pkg /](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/tree/pkg)[kubelet /](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/tree/pkg/kubelet)[util /](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/tree/pkg/kubelet/util)[manager /](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/tree/pkg/kubelet/util/manager)[watch_based_manager.go](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/blob/pkg/kubelet/util/manager/watch_based_manager.go)<br />可以看到，watch_based_manager 最后使用了 NewCacheBasedManager ，所以 watch_based_manager  和 cache_based_manager 不同的是 ObjectStore 字段。


```go
// NewWatchBasedManager creates a manager that keeps a cache of all objects
// necessary for registered pods.
// It implements the following logic:
// - whenever a pod is created or updated, we start individual watches for all
//   referenced objects that aren't referenced from other registered pods
// - every GetObject() returns a value from local cache propagated via watches
func NewWatchBasedManager(
	listObject listObjectFunc,
	watchObject watchObjectFunc,
	newObject newObjectFunc,
	isImmutable isImmutableFunc,
	groupResource schema.GroupResource,
	resyncInterval time.Duration,
	getReferencedObjects func(*v1.Pod) sets.String) Manager {

	// If a configmap/secret is used as a volume, the volumeManager will visit the objectCacheItem every resyncInterval cycle,
	// We just want to stop the objectCacheItem referenced by environment variables,
	// So, maxIdleTime is set to an integer multiple of resyncInterval,
	// We currently set it to 5 times.
	maxIdleTime := resyncInterval * 5

	// TODO propagate stopCh from the higher level.
	objectStore := NewObjectCache(listObject, watchObject, newObject, isImmutable, groupResource, clock.RealClock{}, maxIdleTime, wait.NeverStop)
	return NewCacheBasedManager(objectStore, getReferencedObjects)
}
```

watch_based_manager  通过 watch 而不是简单的 ttl 去确认或者刷新缓存。
