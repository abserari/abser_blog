\### Points
\- set\_concurrency: control the number of thread.
\- pshared: Could share by multi process but not multi threads in one process. Need dynamic init

\### Sync ways

\#### join
pthread\_t thread[NUM\_THREADS]

pthread\_join(threadid,status)

\#### mutex
pthread\_mutex\_t mutex = PTHREAD\_MUTEX\_INITIALIZER

\#### condition
pthread\_cond\_t mutex = PTHREAD\_COND\_INITIALIZER
\`\`\`c
int pthread\_cond\_wait(pthread\_cond\_t \*cptr, pthread\_mutex\_t \*mptr)
int pthread\_cond\_signal(pthread\_cond\_t \*cptr)
\`\`\`

\#### Interrupt
R/W mutex and POSIX signal may not release when abnormal interruption like process exit unexpectedly.

\## Refer

\- [Excellent POSIX Threads Tutorial](https://computing.llnl.gov/tutorials/pthreads/)
\- [POSIX thread libraries - CMU](https://www.cs.cmu.edu/afs/cs/academic/class/15492-f07/www/pthreads.html)
\- [中文 pthread 教程](https://hanbingyan.github.io/2016/03/07/pthread\_on\_linux/#section)