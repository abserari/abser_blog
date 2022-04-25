--- 
layout: category-post
title:  "Welcome to blog!"
date:   2016-08-05 20:20:56 -0400
categories: writing
---

\## multi inheritance with list\_head.
\`\`\`c
typedef struct OLNode {
 int LineNumber, ColumneNumber;
 ElemType value;
 struct OLNode \*right, \*down;
}OLNode, \*OList;
\`\`\`

\### Find History
![linux-address-inheritance.svg](https://cdn.nlark.com/yuque/0/2020/svg/176280/1602407063630-67460085-acb2-45e4-86e2-7f7e6872f422.svg#align=left&display=inline&height=971&margin=%5Bobject%20Object%5D&name=linux-address-inheritance.svg&originHeight=971&originWidth=745&size=52286&status=done&style=none&width=745)

\## Offset

\### small test
\`\`\`c
#include
#include

typedef struct list\_head {
 int count;
}list\_head ;

int ref(struct list\_head \*obj) {
 return obj->count;
}

#define CustomTransfer\_T(a) ( (\_customObject\*) ( ((char\*)a) - \
offsetof(\_customObject,obj\_T) ) )

typedef struct \_customObject {
 int obj;
 int obj\_T;
 int extra;
}\_customObject;

int sum(\_customObject \*obj) {
 return obj->extra+ ref((list\_head\*)&obj->obj) + ref((list\_head\*)&obj->obj\_T);
}

void main() {
 \_customObject custom = {10,11,12};

 printf("%d\\n",ref((list\_head\*)&custom.obj));
 printf("%d\\n",ref((list\_head\*)&custom));
 printf("%d\\n",ref((list\_head\*)(&custom.obj\_T)));

 list\_head\* parent\_T = (list\_head\*)&custom.obj\_T;
 printf("%d\\n",sum(CustomTransfer\_T(parent\_T)));
}
\`\`\`

\### Linux 2.4
Linux 2.4 版本中还是最初质朴的定义, 最好研究

[https://elixir.bootlin.com/linux/2.4.31/source/include/linux/list.h#L187](https://elixir.bootlin.com/linux/2.4.31/source/include/linux/list.h#L187)
\`\`\`c
/\\*\\*
 \\* list\_entry - get the struct for this entry
 \\* @ptr: the &struct list\_head pointer.
 \\* @type: the type of the struct this is embedded in.
 \\* @member: the name of the list\_struct within the struct.
 \*/
#define list\_entry(ptr, type, member) \
 ((type \*)((char \*)(ptr)-(unsigned long)(&((type \*)0)->member)))
\`\`\`

\### Linux 5.9
Linux 5.9 版本中 从 list 寻找 structure 的函数定义转移到了 \`/include/linux/kernel\`

[https://elixir.bootlin.com/linux/v5.9-rc8/source/include/linux/kernel.h#L1000](https://elixir.bootlin.com/linux/v5.9-rc8/source/include/linux/kernel.h#L1000)
\`\`\`c
/\\*\\*
 \\* container\_of - cast a member of a structure out to the containing structure
 \\* @ptr: the pointer to the member.
 \\* @type: the type of the container struct this is embedded in.
 \\* @member: the name of the member within the struct.
 \*
 \*/
#define container\_of(ptr, type, member) ({ \
 void \*\_\_mptr = (void \*)(ptr); \
 BUILD\_BUG\_ON\_MSG(!\_\_same\_type(\*(ptr), ((type \*)0)->member) && \
 !\_\_same\_type(\*(ptr), void), \
 "pointer type mismatch in container\_of()"); \
 ((type \*)(\_\_mptr - offsetof(type, member))); })
\`\`\`