## How Cloud Develop Kit from Google designed the docstore interface

<a name="ljgKZ"></a>
## Refer
- [Docstore · Go CDK](https://gocloud.dev/howto/docstore/)
- [urls.go - google/go-cloud - Sourcegraph](https://sourcegraph.com/github.com/google/go-cloud@master/-/blob/docstore/mongodocstore/urls.go)
- [driver.go - Go](https://cs.opensource.google/go/go/+/refs/tags/go1.18.3:src/database/sql/driver/driver.go)
<a name="Eu7vN"></a>

## Design objectives: 

**through the abstraction layer, we can mask differences, provide services in a standardized way, and configure business applications through description files. **

**Provides design ideas and guidelines for applications that use document storage. **
<a name="yaqn6"></a>
## Intro
common in MongoDB [document Storage](https://en.wikipedia.org/wiki/Document-oriented_database) provides an abstraction layer. 

Document Storage is a service that stores data in semi-structured JSON-like documents. These documents are grouped into collections. Like other NoSQL databases, document storage is modeless. 

The design needs to support adding, retrieving, modifying, and deleting documents. 
docstore Driver implementation of various services, including cloud and local solutions. You can develop applications locally and then reconfigure them to multiple cloud providers with minimal initialization. 
<a name="FCVI2"></a>
## 设计
<a name="fg6xL"></a>
### Structuring Portable Code 
Structuring Portable Code the non-interface design imitates the database/SQL package of golang and wraps the existing common logic into the structure. The internal fields of the structure are driver interfaces. The method provided externally is the method corresponding to the structure rather than the implementation of the direction provided driver.

> The advantage of this design is that there is no need to implement general logic processing for each interface, and the code can be transplanted. In some cases, you only need to add and modify methods on the structure and do not need to destroy the method design in the interface. You can also mask some assertion logic. When switching different drivers, users do not need to determine the implementation of some optional interfaces.

[Structuring Portable Code · Go CDK](https://gocloud.dev/concepts/structure/)
[sql package - database/sql - Go Packages](https://pkg.go.dev/database/sql#DB
![yuque_diagram.jpg](https://cdn.hashnode.com/res/hashnode/image/upload/v1657339087759/HnpeQujl6.jpg align="left")
![yuque_diagram (1).jpg](https://cdn.hashnode.com/res/hashnode/image/upload/v1657339090477/d6gw6aN1x.jpg align="left")


<br />Code like below：
```go
// Define
type DB interface{
    Exec(sql string)error
}

// Realize
type mysql struct {}
func (m *mysql) Exec(sql string) error {return nil}

// Execute
sql.Database.Exec("")
```
```go
// package and structure
package sql

type DB struct {
    driver driver.DB
}

// higher level logic
func (db *DB) AnySignature(anyParams string) (anyReturn error) {
    //... 
    db.driver.Exec("...")
    //...
    return nil
}
// Define
package driver 

type DB interface{
    Exec(sql string)error
}

// Realize
type mysql struct {}
func (m *mysql) Exec(sql string) error {return nil}

// Execute
sql.DB.AnySignature("")
```
<a name="xSKiY"></a>
### Actions List
For MongoDB, batch processing can be carried out to improve efficiency. As the shielding layer of packaging, we hope to obtain this benefit according to the actual processing of driver. A queue or cache is required to submit a batch operation.

[Batch write operations-MongoDB-CN-Manual](https://docs.mongoing.com/mongodb-crud-operations/bulk-write-operations)

- [x] I think it is enough to undertake Google Go CDK design 

<a name="g9Zj6"></a>
### Driver Map & Opener
Inherited from the Mysql Driver registration method, through the golang standard import_" github.com/xxx/driver" different database drivers can be introduced. The principle is to use a global Map.

Go CDK has upgraded the Opener feature. The original custom URL Parsing method is "mysql", "user:password@/dbname" the features of the new version are blob+file:///dir even <api>+ <type>+ prefix (e.g. blob+bucket+file:///dir) for Google Cloud SDK, the same URL can provide different functions. However, in our opinion, this function does not have much effect for the time being, so we will block their design. 

<a name="MrRZi"></a>
### Dependency Injection wire 
Go CDK use the wire project to inject dependencies to automatically switch the structure of different backend providers to the SDK. Different from the way Dapr accesses different services, Dapr uses the yaml description to determine the different plug-ins that are enabled. 

For example, you need wire.Build() indicates the new function of the driver to be introduced. 

It has little impact on this project and may not be added for the time being. 

<a name="tUMOU"></a>

### UUID usage

mongoDB, each entry must have a Key, which can be passed through parameters. 
```go
type Player struct {
    ID   interface{} `docstore:"_id,omitempty"`
    Name string
}
```

The simplest is to indicate the_id field directly in the structure. 

```go
docstore.OpenCollection(context.Background(), "mongo://my-db/my-coll?id_field=name")
```
You can also use the URL Parameter in the high-level abstraction. The following example specifies the_ID as the name field of the above-mentioned high-level abstraction, which is used by the underlying layer `mongodocstore.OpenCollection` mapping relationship, will automatically generate mongo official driver type `primitivie.ObjectID `

```go
coll, err := mongodocstore.OpenCollection(mcoll, "id", nil)

type IDer struct {
	ID primitive.ObjectID
}
```

you can also use `mongodocstore.OpenCollectionWithIDFunc` to specify how to generate an ID.

```go
nameFromDocument := func(doc docstore.Document) interface{} {
    return primitive.NewObjectID()
}
coll, err := mongodocstore.OpenCollectionWithIDFunc(mcoll, nameFromDocument, nil)
```

<a name="F0eWR"></a>
## Summary 
We have completed the access design and understanding of Document Store and can perform basic operations on adding, deleting, modifying, and querying docstores. Next, we will build service applications based on this layer of abstraction. 

For special functions of different docstores, you can add them to docstore to determine whether they are target-driven and change the method of external exposure.

<a name="E8DHr"></a>
## function 

the following shows the functions of the library. 

<a name="hVYIf"></a>
### Connect MongoDB
The default mongo driver uses MONGO_SERVER_URL link to the server, so you can use code to set it here or directly set it by using environment variables. 

the following meaning is from mongodb://localhost:27017 the link on the server is called `my-db`in the database `my-coll` document. The unique field name of mongo is `name`. 

```go
os.Setenv("MONGO_SERVER_URL", "mongodb://localhost:27017")

coll, err := docstore.OpenCollection(context.Background(), "mongo://my-db/my-coll?id_field=name")
defer coll.Close()
```
<a name="HM4A2"></a>
### Corresponding display structure 
```go
type Player struct {
	Name             string `docstore:"name,omitempty"`
	Score            int
	DocstoreRevision interface{}
}
```
<a name="YFPTq"></a>
### Create 
```go
coll.Create(ctx, &Player{Name: "Pat", Score: 7}); 
```
<a name="CuHHJ"></a>
### Get 
```go
coll.Get(ctx, &Player{Name: "Pat"});
```
<a name="syvtX"></a>
### Queries 
you may need to manually create indexes to complete the query function. 
```go
import (
	"context"
	"fmt"
	"io"

	"gocloud.dev/docstore"
)

// Ask for all players with scores at least 20.
iter := coll.Query().Where("Score", ">=", 20).OrderBy("Score", docstore.Descending).Get(ctx)
defer iter.Stop()

// Query.Get returns an iterator. Call Next on it until io.EOF.
for {
	var p Player
	err := iter.Next(ctx, &p)
	if err == io.EOF {
		break
	} else if err != nil {
		return err
	} else {
		fmt.Printf("%s: %d\n", p.Name, p.Score)
	}
}
```
<a name="zif5K"></a>
### Update a single field of an Update entry
```go
pat2 := &Player{Name: "Pat"}
err := coll.Actions().Update(pat, docstore.Mods{"Score": 15}).Get(pat2).Do(ctx)
```
<a name="VJYOy"></a>
### Replace 
completely replace the entire entry 
```go
coll.Replace(ctx, &Player{Name: "Pat", Score: 15})
```
<a name="QjVog"></a>
### Put 
the Put function is equivalent to CreateOrUpdate
```go
coll.Put(ctx, &Player{Name: "Pat", Score: 15})
```
<a name="wzyMJ"></a>
### Delete 
```go
coll.Delete(ctx, &Player{Name: "Pat", Score: 15})
```
<a name="wer1V"></a>
### More examples 

- [CLI Sample](https://github.com/google/go-cloud/tree/master/samples/gocdk-docstore)
- [Order Processor sample](https://gocloud.dev/tutorials/order/)
- [docstore package examples](https://godoc.org/gocloud.dev/docstore#pkg-examples)
