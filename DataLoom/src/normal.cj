package DataLoom
// 先导入所需的标准库
import std.console.*
import std.convert.*
import std.collection.*
import std.sort.*
import std.math.*
import std.io.*
import std.fs.*
//用于打印哈夫曼编码表
public func printHuffmanCodes(HT: Array<HTNode>, codes: Array<String>, n: Int64) {
    println("哈夫曼编码表：")
    println("字符\t权重\t编码")
    for (i in 1..(n + 1)) {
        let char = HT[i].data
        let weight = HT[i].weight
        let code = codes[i - 1]
        println("${char}\t${weight}\t${code}")
    }
}

func menu() {
    println("1.解密")
    println("2.构建哈夫曼树加密")
    println("3.退出程序")

    println("请输入操作序号")
}
func copyright(){
    println(  "*****************************************************************")
    println(  "This program is DataLoom")
    println(  "Copyright 2025 WuShuo ZhangJinRong ZhangYuanYuan")
    println(  "All rights reserved.")
    println(  "*****************************************************************")
}
// 选择输入方法（从文件或键盘）
func chooseInputMethod(): Int64 {
    println("请选择字符和权值输入方式: ")
    println("1. 从文件读取字符和权值")
    println("2. 从键盘输入字符和权值")
    while (true) {
        print("选择输入方式 (1 或 2): ")
        let input = Console.stdIn.readln().getOrThrow()
        try {
            let choice = Int64.parse(input)
            if (choice == 1 || choice == 2) {
                return choice
            } else {
                println("无效输入，请重新输入 1 或 2。")
            }
        } catch (e: Exception) {
            println("输入格式错误，请输入数字 1 或 2。")
        }
    }
    return 1 // 为了防止警告，理论上不会执行到这里
}

// 选择操作（加密、解密或退出）
func chooseAction(): Int {
    println("请选择操作: ")
    println("1. 加密")
    println("2. 解密")
    println("3. 退出")
    while (true) {
        print("选择操作 (1, 2 或 3): ")
        let input = Console.stdIn.readln().getOrThrow() // 默认选择第一种操作
        try {
            let choice = Int.parse(input)
            if (choice == 1 || choice == 2 || choice == 3) {
                return choice
            } else {
                println("无效输入，请重新输入 1, 2 或 3。")
            }
        } catch (e: Exception) {
            println("输入格式错误，请输入数字 1, 2 或 3。")
        }
    }
    return 1
}
// 从键盘读取消息
func readMessageFromKeyboard(): String {
    println("请输入正文内容:")
    try {
        return Console.stdIn.readln().getOrThrow()
    } catch (e: Exception) {
        println("读取输入时发生错误: ${e.message}")
        return ""
    }
}

func readSeq() {
    // 初始化时从配置文件读取序号
    try {
        treeSequenceNumber = readTreeSequenceFromConfig()
    } catch (e: Exception) {
        println("num is ${treeSequenceNumber}")
    }
    println("当前哈夫曼树序号为: ${treeSequenceNumber}")
}
// 将哈希表转换为构建哈夫曼树所需的数组格式
func convertHashToData(hash: HashMap<Rune, Int64>): Array<(Rune, Int64)> {
    var data = Array<(Rune, Int64)>(hash.size, item: (r'0', 0))
    var index = 0
    for ((char, freq) in hash) {
        data[index] = (char, freq)
        index += 1
    }
    return data
}
public func readFileMessage(filename: String, s: String) /*: HashMap<Rune, Int64>*/ {
    var hash: HashMap<Rune, Int64> = HashMap<Rune, Int64>()
    let x = File.readFrom(filename)
    var y: Int64 = 0
    var z: Rune = '0'
    var flag = 0
    println(x)
    for (i in 0..x.size) {
        if (flag == 1) {
            flag = 0
            continue
        }
        if (i == 0) {
            z = Rune(x[0])
            flag = 1
            continue
        }
        if (x[i] == 10) {
            hash[z] = y
            flag = 1
            y = 0
            if (i != x.size - 1) {
                z = Rune(x[i + 1])
            }
        } else {
            var t = Int64(x[i])
            if (t != 32) {
                y = y * 10 + Int64(x[i]) - 48
            }
        }
    }
    println("s is ${s}")
    buildAndUseHuffmanTree(hash, s) //调用函数对生成的hash表进行编码译码 
}
// 从文件中读取消息内容
func readMessageFromFile(filename: String): ?String {
    if (!File.exists(filename)) {
        println("文件 ${filename} 不存在")
        return None
    }
    try (file = File.openRead(filename), reader = StringReader(file)) {
        return reader.readToEnd()
    } catch (e: Exception) {
        println("读取文件时发生错误: ${e.message}")
    }
    return None
}
// 将哈夫曼树序列号存储到配置文件
func storeTreeSequenceToConfig() {
    let path = Path(configFilename)
    if (File.exists(path)) {
        File.delete(path)
    }
    try (configFile = File.create(configFilename), writer = StringWriter(configFile)) {
        writer.write("${treeSequenceNumber}\n")
    } catch (e: Exception) {
        println("无法写入配置文件: ${e.message}")
    }
}
// 从配置文件中读取哈夫曼树序列号,如果不存在直接返回0，否则返回其编号
func readTreeSequenceFromConfig(): Int64 {
    if (!File.exists(configFilename)) {
        println("当前文件不存在,使用默认序号0")
        return 0
    }
    let x = File.readFrom(configFilename)
    var y: Int64 = 0
    for (i in 0..x.size - 1) {
        y = y * 10 + Int64(x[i] - 48)
    }
    return y
}

// 从文件中读取字符和编码映射
func readCharacterMappingFromFile(filename: String): ?Array<(Rune, String)> {
    if (!File.exists(filename)) {
        println("文件 ${filename} 不存在")
        return None
    }
    try (file = File.openRead(filename), reader = StringReader(file)) {
        let content = reader.readToEnd()
        var lines = content.split("\n")
        var mapping = Array<(Rune, String)>(lines.size, item: (r'0', ""))
        for (i in 0..lines.size) {
            let parts = lines[i].split(" ")
            if (parts.size == 2) {
                mapping[i] = (Rune(parts[0][0]), parts[1])
            } else {
                println("文件格式错误")
                return None
            }
        }
        return mapping
    } catch (e: Exception) {
        println("读取映射文件时发生错误: ${e.message}")
    }
    return None
}

// 计算字符频率及可能出现的错误避免
func calculateCharacterFrequencies(message: String): Array<(Rune, Int64)> {
    var frequencyMap = HashMap<Rune, Int64>()
    for (char in message) {
        let currentCount = frequencyMap.get(Rune(char)) ?? 0
        frequencyMap.put(Rune(char), currentCount + 1)
    }

    var result = Array<(Rune, Int64)>(frequencyMap.size, item: (r'0', 0))
    var index = 0
    for ((char, freq) in frequencyMap) {
        result[index] = (char, freq)
        index += 1
    }

    return result
}
