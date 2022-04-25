--- 
layout: category-post
title:  "Welcome to blog!"
date:   2016-08-05 20:20:56 -0400
categories: writing
---

\`\`\`go
func mallocinit() {
 if class\_to\_size[\_TinySizeClass] != \_TinySize {
 throw("bad TinySizeClass")
 }

 testdefersizes()

 // 检查物理页大小
 if physPageSize == 0 {
 // 操作系统初始化代码获取物理页大小失败
 throw("failed to get system page size")
 }
 if physPageSize < minPhysPageSize {
 print("system page size (", physPageSize, ") is smaller than minimum page size (", minPhysPageSize, ")\\n")
 throw("bad system page size")
 }
 if physPageSize&(physPageSize-1) != 0 {
 print("system page size (", physPageSize, ") must be a power of 2\\n")
 throw("bad system page size")
 }

 // 内存区域从 p 开始，在内存中以: span, bitmap, arena 的顺序排列
 var p, pSize uintptr
 var reserved bool

 // span 数组中，对每一块 \_PageSize 的 arena 内存都持有一个 \*mspan
 var spansSize uintptr = (\_MaxMem + 1) / \_PageSize \* sys.PtrSize
 spansSize = round(spansSize, \_PageSize)
 // 每一个 word 的 arena 区域都在 bitmap 中占用 2 bits
 var bitmapSize uintptr = (\_MaxMem + 1) / (sys.PtrSize \* 8 / 2)
 bitmapSize = round(bitmapSize, \_PageSize)

 // 初始化内存分配 arena，arena 是一段连续的内存，负责数据的内存分配。
 if sys.PtrSize == 8 {
 // 在 64 位机器上，分配一段连续的内存区域 512 GB(MaxMem) 现在应该是足够了。
 //
 // 代码应该能够用任意地址进行工作，但可能的情况下尽量让 sysReserve 使用 0x0000XXc000000000 (xx=00...7f)。
 // 分配 512 GB 的地址需要用掉 39 bits 来进行地址表达，amd64 平台不允许用户使用高位 17 bits
 // 所以只剩下中间的 0x00c0 中的 9 bits 能让我们用了。选择 0x00c0 表示合法的内存地址是从
 // 0x00c0, 0x00c1, ..., 0x00df 开始
 // 在小端系统上，即 c0 00, c1 00, ..., df 00。这些都不是合法的 UTF-8 序列，且距离 ff(常用的单字节) 足够远。
 // 如果分配失败，会尝试其它 0xXXc0 地址。
 // 之前使用 0x11f8 地址在 OS X 系统上会在线程分配的时候导致 out of memory 错误。
 // 0x00c0 会导致和 AddressSanitizer 的冲突，AddressSanitizer 会将 0x0100 以下的地址都进行保留
 // 这种选择是为了可调试性，且可以限制垃圾收集器(gccgo 中的版本)的保守性，以使其不要收集那些符合一定模式的内存地址中的内存。
 //
 // 实际上我们会保留 544 GB(因为 bitmap 需要用 32 GB)
 // 不过这不重要: e0 00 也不是合法的 UTF-\* 字符
 //
 // 如果失败，会回退到 32 位内存策略
 //
 // 然而在 arm64 平台我们会忽略上面所有的建议，直接梭哈分配到 0x40 << 32，因为
 // 使用 4k 页搭配 3级 TLB 时，用户地址空间会被限制在 39 位能表达的范围之内，
 // 在 darwin/arm64 上，地址空间就更小了。
 arenaSize := round(\_MaxMem, \_PageSize)
 pSize = bitmapSize + spansSize + arenaSize + \_PageSize
 for i := 0; i <= 0x7f; i++ {
 switch {
 case GOARCH == "arm64" && GOOS == "darwin":
 p = uintptr(i)<<40 \| uintptrMask&(0x0013<<28)
 case GOARCH == "arm64":
 p = uintptr(i)<<40 \| uintptrMask&(0x0040<<32)
 default:
 p = uintptr(i)<<40 \| uintptrMask&(0x00c0<<32)
 }
 p = uintptr(sysReserve(unsafe.Pointer(p), pSize, &reserved))
 if p != 0 {
 break
 }
 }
 }

 if p == 0 {
 // 在 32 位机器上，我们没法简单粗暴地获得一段巨大的虚拟地址空间，并保留内存。
 // 取而代之，我们将内存信息的 bitmap 紧跟在 data segment 之后，
 // 这样做足够处理整个 4GB 的内存空间了(256 MB 的 bitmap 消耗)
 // 初始化阶段会保留一小段地址
 // 用完之后，我们再和 kernel 申请其它位置的内存。

 // 我们想要让 arena 区域从低地址开始，但是我们的代码可能和 C 代码进行链接，
 // 全局的构造器可能已经调用过 malloc，并且调整过进程的 brk 位置。
 // 所以需要查询一次 brk，以避免将我们的 arena 区域覆盖掉 brk 位置，
 // 这会导致 kernel 把 arena 放在其它地方，比如放在高地址。
 procBrk := sbrk0()

 // 如果分配失败，那么尝试用更小一些的 arena 区域。
 // 对于像 Android L 这样的系统是需要的，因为我们和 ART 更新同一个进程，
 // 其会更激进地保留内存。
 // 最差的情况下，会退化为 0 大小的初始 arena
 // 这种情况下希望之后紧跟着的内存保留操作能够成功。
 arenaSizes := []uintptr{
 512 << 20,
 256 << 20,
 128 << 20,
 0,
 }

 for \_, arenaSize := range arenaSizes {
 // sysReserve 会把我们要求保留的地址的末尾作为一种 hint，而不一定会满足
 // 这种情况下需要我们自己对指针进行 roundup，先是 1/4 MB，以使其离开运行的二进制
 // 镜像位置，然后在 roundup 到 MB 的边界位置

 p = round(firstmoduledata.end+(1<<18), 1<<20)
 pSize = bitmapSize + spansSize + arenaSize + \_PageSize
 if p <= procBrk && procBrk < p+pSize {
 // 将 start 移动到 brk 之上，给未来的 brk 扩展保留一些空间
 p = round(procBrk+(1<<20), 1<<20)
 }
 p = uintptr(sysReserve(unsafe.Pointer(p), pSize, &reserved))
 if p != 0 {
 break
 }
 }
 if p == 0 {
 throw("runtime: cannot reserve arena virtual address space")
 }
 }

 // PageSize 可能被 OS 定义的 page size 更大
 // 所以 sysReserve 会返回给我们一个未 PageSize-对齐的指针。
 // 我们需要对其进行 round up，以使其按我们的 PageSize 要求对齐
 p1 := round(p, \_PageSize)
 pSize -= p1 - p

 spansStart := p1
 p1 += spansSize
 mheap\_.bitmap = p1 + bitmapSize
 p1 += bitmapSize
 if sys.PtrSize == 4 {
 // 赋值 arena\_start 这样我们相当于接受了 4GB 虚拟空间中的保留内存
 mheap\_.arena\_start = 0
 } else {
 mheap\_.arena\_start = p1
 }
 mheap\_.arena\_end = p + pSize
 mheap\_.arena\_used = p1
 mheap\_.arena\_alloc = p1
 mheap\_.arena\_reserved = reserved

 if mheap\_.arena\_start&(\_PageSize-1) != 0 {
 println("bad pagesize", hex(p), hex(p1), hex(spansSize), hex(bitmapSize), hex(\_PageSize), "start", hex(mheap\_.arena\_start))
 throw("misrounded allocation in mallocinit")
 }

 // 初始化分配器的剩余部分
 mheap\_.init(spansStart, spansSize)
 \_g\_ := getg()
 \_g\_.m.mcache = allocmcache()
}
\`\`\`