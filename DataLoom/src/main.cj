package DataLoom

// 先导入所需的标准库
import std.console.*
import std.convert.*
import std.collection.*
import std.sort.*
import std.math.*
import std.io.*
import std.fs.*
func copyright();
main(): Int64 {
    copyright();
    while (true) {
        menu()
        let txt = Console.stdIn.readln().getOrThrow()
        let c = Int.parse(txt)
        if (c == 1) {
            println("请输入密文")
            var s1: String = Console.stdIn.readln().getOrThrow() //readString()
            var s = ASE_decode(s1)
            println("请输入哈夫曼树编号")
            let tx = Console.stdIn.readln().getOrThrow()
            let d = Int.parse(tx)
            let filename = "Tree_${tx}.txt"
            if (!File.exists(filename)) {
                println("文件 ${filename} 不存在")
                break
            }
            readFileMessage(filename, s)
        } else if (c == 2) {
            readSeq()
            // 选择正文输入方式
            let inputMethod = chooseInputMethod()
            var message = ""
            if (inputMethod == 1) {
                println("请输入文件名:")
                let filename = Console.stdIn.readln().getOrThrow()
                let content = readMessageFromFile(filename)
                if (content.isSome()) {
                    message = content.getOrThrow()
                } else {
                    println("读取文件失败，退出程序")
                    return 0
                }
            } else {
                message = readMessageFromKeyboard()
            }
            encrypt(message)
        } else if (c == 3) {
            println("程序执行完毕")
        } else {
            println("无效输入，请重新输入")
        }
    }
    return 0
}
