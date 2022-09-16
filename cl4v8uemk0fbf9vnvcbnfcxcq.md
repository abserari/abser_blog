## Node Status Manager

<a name="eQr2o"></a>
## ReadLink
- [pkg/kubelet/nodestatus/setters.go](https://sourcegraph.com/github.com/kubernetes/kubernetes/-/blob/pkg/kubelet/nodestatus/setters.go)
- [/](https://sourcegraph.com/github.com/kubernetes/kubernetes@d2c5779dadc9ed7a462c36bc280b2f9a200c571e)[pkg /](https://sourcegraph.com/github.com/kubernetes/kubernetes@d2c5779dadc9ed7a462c36bc280b2f9a200c571e/-/tree/pkg)[kubelet /](https://sourcegraph.com/github.com/kubernetes/kubernetes@d2c5779dadc9ed7a462c36bc280b2f9a200c571e/-/tree/pkg/kubelet)[kubelet_node_status.go](https://sourcegraph.com/github.com/kubernetes/kubernetes@d2c5779dadc9ed7a462c36bc280b2f9a200c571e/-/blob/pkg/kubelet/kubelet_node_status.go)

<a name="HvtiD"></a>
## Directory Layout
```go
pkg/kubelet/nodestatus
 |- setters.go
 |- setters_test.go
```
<a name="ABxjo"></a>
## Setter
```go
// Setter modifies the node in-place, and returns an error if the modification failed.
// Setters may partially mutate the node before returning an error.
type Setter func(node *v1.Node) error
```
the Setter function defines a function that performs operations on the v1.Node object. If an error is returned, the Node object may also be changed. 
From the function definition, you can see its usage: use functions to generate different setters for a class of modification of Node objects. In this way, you can modify the state of a Node. 
Use the simplest func GoRuntime() Setter example: 
```go
// GoRuntime returns a Setter that sets GOOS and GOARCH on the node.
func GoRuntime() Setter {
	return func(node *v1.Node) error {
		node.Status.NodeInfo.OperatingSystem = goruntime.GOOS
		node.Status.NodeInfo.Architecture = goruntime.GOARCH
		return nil
	}
}
```
this mode belongs to the middleware operation mode. You can contact middleware for understanding. 
<a name="E3eSp"></a>
## Setter List
we learned the setter mode changed by Node status. Currently, the code contains the following 12 setters:
- **NodeAddress **returns a Setter that updates address-related information on the node.：updates address-related fields, such as IP address and hostname (typically the hostname variable in kubelet). 
- **MachineInfo **returns a Setter that updates machine-related information on the node.：updates fields related to host information, such as the maximum number of pods, the number of pods allocated to each core, and the number of resources. 
- **VersionInfo **returns a Setter that updates version-related information on the node.：containerRuntime version, cadvisor version
- **DaemonEndpoints **returns a Setter that updates the daemon endpoints on the node.
- **Images **returns a Setter that updates the images on the node.：updates image information. 
- **GoRuntime **returns a Setter that sets GOOS and GOARCH on the node.：GOOS GOARCH information 
- **ReadyCondition** returns a Setter that updates the v1.NodeReady condition on the node.：determines whether the node is in the Ready state from Kubelet fields such as the error return function in the runtimeState. 
- **MemoryPressureCondition **returns a Setter that updates the v1.NodeMemoryPressure condition on the node.
- **PIDPressureCondition **returns a Setter that updates the v1.NodePIDPressure condition on the node.
- **DiskPressureCondition **returns a Setter that updates the v1.NodeDiskPressure condition on the node.
- **VolumesInUse **returns a Setter that updates the volumes in use on the node.
- **VolumeLimits **returns a Setter that updates the volume limits on the node.


Setter 的入参通常是 Kubelet 中的字段，自然使用是通过 Kubelet 去初始化使用。
<a name="uRi9a"></a>
## Kubelet Node Status
[/](https://sourcegraph.com/github.com/kubernetes/kubernetes@d2c5779dadc9ed7a462c36bc280b2f9a200c571e)[pkg /](https://sourcegraph.com/github.com/kubernetes/kubernetes@d2c5779dadc9ed7a462c36bc280b2f9a200c571e/-/tree/pkg)[kubelet /](https://sourcegraph.com/github.com/kubernetes/kubernetes@d2c5779dadc9ed7a462c36bc280b2f9a200c571e/-/tree/pkg/kubelet)[kubelet_node_status.go](https://sourcegraph.com/github.com/kubernetes/kubernetes@d2c5779dadc9ed7a462c36bc280b2f9a200c571e/-/blob/pkg/kubelet/kubelet_node_status.go)
<a name="LGGvP"></a>
###  Setter 使用处
after all setters are initialized in the defaultNodeStatusFuncs function, the function returns a Setter array. 

[kubelet_node_status.go? L613](https://sourcegraph.com/github.com/kubernetes/kubernetes@d2c5779dadc9ed7a462c36bc280b2f9a200c571e/-/blob/pkg/kubelet/kubelet_node_status.go?L613)

```go
// defaultNodeStatusFuncs is a factory that generates the default set of
// setNodeStatus funcs
func (kl *Kubelet) defaultNodeStatusFuncs() []func(*v1.Node) error {
	// if cloud is not nil, we expect the cloud resource sync manager to exist
	var nodeAddressesFunc func() ([]v1.NodeAddress, error)
	if kl.cloud != nil {
		nodeAddressesFunc = kl.cloudResourceSyncManager.NodeAddresses
	}
	var validateHostFunc func() error
	if kl.appArmorValidator != nil {
		validateHostFunc = kl.appArmorValidator.ValidateHost
	}
	var setters []func(n *v1.Node) error
	setters = append(setters,
		nodestatus.NodeAddress(kl.nodeIPs, kl.nodeIPValidator, kl.hostname, kl.hostnameOverridden, kl.externalCloudProvider, kl.cloud, nodeAddressesFunc),
		nodestatus.MachineInfo(string(kl.nodeName), kl.maxPods, kl.podsPerCore, kl.GetCachedMachineInfo, kl.containerManager.GetCapacity,
			kl.containerManager.GetDevicePluginResourceCapacity, kl.containerManager.GetNodeAllocatableReservation, kl.recordEvent),
		nodestatus.VersionInfo(kl.cadvisor.VersionInfo, kl.containerRuntime.Type, kl.containerRuntime.Version),
		nodestatus.DaemonEndpoints(kl.daemonEndpoints),
		nodestatus.Images(kl.nodeStatusMaxImages, kl.imageManager.GetImageList),
		nodestatus.GoRuntime(),
	)
	// Volume limits
	setters = append(setters, nodestatus.VolumeLimits(kl.volumePluginMgr.ListVolumePluginWithLimits))

	setters = append(setters,
		nodestatus.MemoryPressureCondition(kl.clock.Now, kl.evictionManager.IsUnderMemoryPressure, kl.recordNodeStatusEvent),
		nodestatus.DiskPressureCondition(kl.clock.Now, kl.evictionManager.IsUnderDiskPressure, kl.recordNodeStatusEvent),
		nodestatus.PIDPressureCondition(kl.clock.Now, kl.evictionManager.IsUnderPIDPressure, kl.recordNodeStatusEvent),
		nodestatus.ReadyCondition(kl.clock.Now, kl.runtimeState.runtimeErrors, kl.runtimeState.networkErrors, kl.runtimeState.storageErrors, validateHostFunc, kl.containerManager.Status, kl.shutdownManager.ShutdownStatus, kl.recordNodeStatusEvent),
		nodestatus.VolumesInUse(kl.volumeManager.ReconcilerStatesHasBeenSynced, kl.volumeManager.GetVolumesInUse),
		// TODO(mtaufen): I decided not to move this setter for now, since all it does is send an event
		// and record state back to the Kubelet runtime object. In the future, I'd like to isolate
		// these side-effects by decoupling the decisions to send events and partial status recording
		// from the Node setters.
		kl.recordNodeSchedulableEvent,
	)
	return setters
}
```
The array is assigned to the setNodeStatusFuncs of kubelet.
```go
	// Generating the status funcs should be the last thing we do,
	// since this relies on the rest of the Kubelet having been constructed.
	klet.setNodeStatusFuncs = klet.defaultNodeStatusFuncs()
```
<a name="n0m8P"></a>
## SyncNodeStatus Procedure
how do Kubelet use these Kubelet? The core is syncNodeStatus functions.

[kubelet_node_status](https://sourcegraph.com/github.com/kubernetes/kubernetes@d2c5779dadc9ed7a462c36bc280b2f9a200c571e/-/blob/pkg/kubelet/kubelet_node_status.go?L435)
```go
// syncNodeStatus should be called periodically from a goroutine.
// It synchronizes node status to master if there is any change or enough time
// passed from the last sync, registering the kubelet first if necessary.
func (kl *Kubelet) syncNodeStatus() {
	kl.syncNodeStatusMux.Lock()
	defer kl.syncNodeStatusMux.Unlock()

	if kl.kubeClient == nil || kl.heartbeatClient == nil {
		return
	}
	if kl.registerNode {
		// This will exit immediately if it doesn't need to do anything.
		kl.registerWithAPIServer()
	}
	if err := kl.updateNodeStatus(); err != nil {
		klog.ErrorS(err, "Unable to update node status")
	}
}
```
syncNodeStatus the function is called periodically in goroutine to synchronize the node status to the master.
<a name="bdMgb"></a>
### 入口 Entry
currently, it is called in three places: 

1. [kubelet.go? L1428:26](https://sourcegraph.com/github.com/kubernetes/kubernetes@d2c5779dadc9ed7a462c36bc280b2f9a200c571e/-/blob/pkg/kubelet/kubelet.go?L1428:26)
in the Run function of the Kubelet, start goroutine for periodic synchronization. 
```go
go wait.JitterUntil(kl.syncNodeStatus, kl.nodeStatusUpdateFrequency, 0.04, true, wait.NeverStop)
```

2. [kubelet.go? L2433:7](https://sourcegraph.com/github.com/kubernetes/kubernetes@d2c5779dadc9ed7a462c36bc280b2f9a200c571e/-/blob/pkg/kubelet/kubelet.go?L2433:7)
: performs one-time synchronization in the fastStatusUpdateOnce function.
```go
func (kl *Kubelet) fastStatusUpdateOnce() {
	for {
		...
        kl.syncNodeStatus()
        return
	}
}
```

3. [nodeshutdown_manager_linux.go? L283:11](https://sourcegraph.com/github.com/kubernetes/kubernetes@d2c5779dadc9ed7a462c36bc280b2f9a200c571e/-/blob/pkg/kubelet/nodeshutdown/nodeshutdown_manager_linux.go?L283:11)
: it is called in the start() function of nodeshutdownmanager, which is actually a goroutine and is triggered only after the shutdown event is received from the channel.
```go
if isShuttingDown {
    // Update node status and ready condition
    go m.syncNodeStatus()

    m.processShutdownEvent()
} 
```

<a name="FKaYq"></a>
### 注册 RegisterWithAPIserver
if kubelet needs to be registered, a for loop is executed to wait for registration to the APIServer.
```go
for {
    time.Sleep(step)
    step = step * 2
    if step >= 7*time.Second {
        step = 7 * time.Second
    }

    // 1. 获取 node 对象及其信息
    node, err := kl.initialNode(context.TODO())
    if err != nil {
        klog.ErrorS(err, "Unable to construct v1.Node object for kubelet")
        continue
    }

    klog.InfoS("Attempting to register node", "node", klog.KObj(node))
    // 2. 注册到 APIServer 中去
    registered := kl.tryRegisterWithAPIServer(node)
    if registered {
        klog.InfoS("Successfully registered node", "node", klog.KObj(node))
        kl.registrationCompleted = true
        return
    }
}
```

1. node, err := kl.initialNode(context.TODO()) : obtains the node object and its information. 
2. registered := kl.tryRegisterWithAPIServer(node) : Register to APIServer 

<a name="bj9z5"></a>
### Use Setter
[Function tryUpdateNodeStatus (kubelet_node_status.go? L470:20)](https://sourcegraph.com/github.com/kubernetes/kubernetes@d2c5779dadc9ed7a462c36bc280b2f9a200c571e/-/blob/pkg/kubelet/kubelet_node_status.go?L470:20)
: the processing part of the volumeManager is omitted.
```go
// tryUpdateNodeStatus tries to update node status to master if there is any
// change or enough time passed from the last sync.
func (kl *Kubelet) tryUpdateNodeStatus(tryNumber int) error {
    originalNode := node.DeepCopy()
    ...
	kl.setNodeStatus(node)
    ...
	// Patch the current status on the API server
	updatedNode, _, err := nodeutil.PatchNodeStatus(kl.heartbeatClient.CoreV1(), types.NodeName(kl.nodeName), originalNode, node)
    ...
	return nil
}
```
kl.setNodeStatus just traverses all the Setter functions we mentioned just now.

```go
func (kl *Kubelet) setNodeStatus(node *v1.Node) {
	for i, f := range kl.setNodeStatusFuncs {
		klog.V(5).InfoS("Setting node status condition code", "position", i, "node", klog.KObj(node))
		if err := f(node); err != nil {
			klog.ErrorS(err, "Failed to set some node status fields", "node", klog.KObj(node))
		}
	}
}
```
<a name="GWa5D"></a>
## Conclusion
we have learned: 
1. what are the change functions of the Node Status and what rules are followed to sign the function.
2. how to register a Setter function to a Kubelet. 
3. Kubelet when these setters are called to change the status of a Node. 

Next: 

1. you can try to add a custom setter function. 
2. Kubernetes code is not as neat as the design. Some todo can be changed after reading this article and code. Try to decouple the code. (You can also find it by searching todo in the code.)
