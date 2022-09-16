## React Hooks State Persistence


> this article describes how to analyze and design State persistence management through React Hooks. 


<a name="UKo9E"></a>
## Analysis 
Normal frontend, components are class files, maintain their own status, and are not easy to reuse. 

First, separate the UI and status of the component and connect them with Action, as shown in the following figure. <br />
![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1657440595754/NW6YDPVEi.png align="left")
[UI=f(State).png](https://cdn.nlark.com/yuque/0/2019/png/176280/1573654060345-7a199253-b266-4610-8632-066e77adf5c3.png#align=left&display=inline&height=202&name=UI%3Df%28State%29.png&originHeight=202&originWidth=483&size=9830&status=done&width=483)<br />Action is an operator 



![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1657441035222/Mu-Hkly0q.png align="left")
[image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1657440676286/8Q_TMIEZg.png align="left")

<a name="sLZem"></a>

![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1657441146096/PdfOku6Mb.png align="left")

According to the Hooks, useState() method  [`Object.is` comparison algorithm](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/is#Description) <br />

To compare the state. And useEffect() then provide choose to let it when [only some values change](https://zh-hans.reactjs.org/docs/hooks-reference.html#conditionally-firing-an-effect)


<a name="Qecoo"></a>
## Design 
<a name="xJtzD"></a>
### virtual part Mathematical model 
the real number is not complete, and the imaginary part is introduced. 

Imaginary number, you only need to remove the imaginary part to represent the real number. 

The same is true for Curry Func. 

Similarly: f(S,∆) medium f(S) represents a real number, which is incomplete. You can add the preceding statement to indicate all the situations. 

The changed dimension changes from a one-dimensional line to a two-dimensional plane. 

In addition, the framework uses f(S, ∆) it is still a one-dimensional line, but it is actually any line of the plane because f(S,...) has already been determined by the user, that is, a plane dimension reduction is selected in multiple dimensions in the code. 

<a name="jXrGs"></a>
### Persistence 
you need to store data in one place, such as local,session, and remote. 

<a name="LJJB8"></a>
### Connector
how does a component distribute triggered events to the State for processing? Communication is required. 
Due to the js single-thread model, the shared memory design is selected. Add a Connector communication. 
The Component Component is how to notify the State of changes. Shared memory, using Connector middle layer. 

<a name="jMcA5"></a>
### Action by CurryFunc
how do I know which states have been changed by the framework user-defined Action? That is, the specific value of azone is unknown. Use Curry Func to meet the requirement of delay evaluation. 
Use fg(S){return f(∆) } replace f(S,∆) 
use the State framework by users themselves f(∆) register your own state change operator. 
State framework for developers fg(S) , just pass in all the State. 
Due to the existence of the React Hooks, the state is used. f(S,∆) the function to update. Therefore, the framework leaves useState() interface and returns f(∆)

For user status management. 

Redux is also based on this function model, which has been officially used in Hooks. useReducer(reducer, initialState) it is implemented. The reducer is set f(S,∆) , and it returns state and dispatch, where state is S A and dispatch is f(∆) 

<a name="PWE1t"></a>
#### Redux
Redux is also based on this function model, which has been officially used in Hooks. useReducer(reducer, initialState) it is implemented. The reducer is set f(S,∆) , and it returns state and dispatch, where state is S A and dispatch is f(∆) 

```javascript
function useReducer(reducer, initialState) {
  const [state, setState] = useState(initialState);
  function dispatch(action) {
    const nextState = reducer(state, action);
    setState(nextState);
  }
  return [state, dispatch];
}
```
in our view, it also implements Connector internally. 

<a name="YbrjG"></a>
## Implementation 


<a name="j5YSm"></a>
#### Persistence 
the first is to implement storage through Hooks, using Local Store 

```go
function useLocalJSONStore(key, defaultValue) {
    const [state, setState] = useState(
      () => JSON.parse(localStorage.getItem(key)) || defaultValue
    );
    useEffect(() => {
      localStorage.setItem(key, JSON.stringify(state));
    }, [key, state]);
    return [state, setState];
}
```

provides persistent storage and external state management support. Considering that we will use Go as the front end: 
1. use Hooks and sqlite3 to store locally 
1. use Hooks to communicate with Go 

<a name="QohKn"></a>
### Connector

to implement global status notifications using Hooks. 
First understand useState() to access to setState() will trigger the current component rendering: https://zh-hans.reactjs.org/docs/hooks-state.html 
Connector let using global state components subscription to connect on the global status updates, will own setState()Pass in the update queue when any of the components use dispatch() 
﻿
import { useEffect } from "react"

```javascript
import { useEffect } from "react"

const Connector = {}

const Broadcast = (name, state) => {
    if (!Connector[name]) return;
    Connector[name].forEach(setter => setter(state))
}

const Subscribe = (name, setter) => {
    if (!Connector[name]) Connector[name] =[];
    Connector[name].push(setter)
}

const UnSubscribe = (name, setter) => {
    if (!Connector[name]) return
    const index = Connector[name].indexOf(setter)
    if (index !== -1) Connector[name].splice(index, 1)
}

const connect = (name,setState) => {
    console.log('connect')
    useEffect(() =>{
        Subscribe(name, setState)
        console.log('subscirbe',name)
        return () => {
            UnSubscribe(name,setState)
            console.log('unsubscribe',name)
        }
    },[])
}
```

<a name="hdQJd"></a>
### useStore
user usage useStore() to obtain the global status and dispatch() function. The internal implementation is to State Hook and get setState() register to the subscription list.

```javascript
import {Broadcast,connect} from './Connector'
import {useState} from 'react'

export function useStore(key,value) {
    const [state,setState] = useState(value)
    connect(key,setState)

    return [state, (key,value) => {
        Broadcast(key,value)
    }]
}

```

<a name="08Fua"></a>
### Current status


![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1657440769721/4fTwvVDYB.png align="left")

<a name="CGlbn"></a>
## Use 
Use useStore(key, value) OK.

```javascript
import {useStore} from './useStore'

export function Counter({key,initialCount}) {
    // const [count, setCount] = useLocalJSONStore(keyname, initialCount);
    const [state, dispatch] = useStore(key,initialCount)
    return (
      <>
        Count: {state}
        <button onClick={() => dispatch(keyname,initialCount)}>Reset</button>
        <button onClick={() => dispatch(keyname,state-1)}>-</button>
        <button onClick={() => dispatch(keyname,state+1)}>+</button>
      </>
    );
  }
```


![image.png](https://cdn.hashnode.com/res/hashnode/image/upload/v1657440784966/shVVNrBRj.png align="left")

<a name="BctcG"></a>
## Advanced  

- [ ] asynchronous status
- [ ] Decorator
