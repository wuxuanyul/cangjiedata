package DataLoom
// 先导入所需的标准库
import std.console.*
import std.convert.*
import std.collection.*
import std.sort.*
import std.math.*
import std.io.*
import std.fs.*

// 类 HTNode 用于表示哈夫曼树的节点
public class HTNode {
    var data: Rune // 节点存储的数据（字符）
    var parent: Int64 // 父节点的索引
    var lchild: Int64 // 左子节点的索引
    var rchild: Int64 // 右子节点的索引
    var weight: Int64 // 节点的权重

    // 默认构造函数，初始化为默认值
    init() {
        this.data = r'0'
        this.weight = 0
        this.parent = 0
        this.lchild = 0
        this.rchild = 0
    }

    // 带参数的构造函数，初始化节点信息
    init(data: Rune, weight: Int64, parent: Int64, lchild: Int64, rchild: Int64) {
        this.data = data
        this.weight = weight
        this.parent = parent
        this.lchild = lchild
        this.rchild = rchild
    }
}
// 创建哈夫曼树，并增加异常处理和提示
public func createHuffmanTree(data: Array<(Rune, Int64)>, n: Int64): Array<HTNode> {
    if (n <= 1) {
        println("需要至少2个字符构建哈夫曼树")
        return Array<HTNode>()
    }

    let m = 2 * n - 1
    var HT: Array<HTNode> = Array<HTNode>((m + 1), item: HTNode())

    // 初始化哈夫曼树叶子节点
    for (i in 1..=n) {
        let (char, weight) = data[i - 1]
        HT[i] = HTNode(char, weight, 0, 0, 0)
    }

    // 构造哈夫曼树
    for (i in (n + 1)..=m) {
        let (s1, s2) = _selectMinNodes(HT, Range<Int64>(1, i, 1, true, true, false))
        if (s1 == -1 || s2 == -1) {
            println("未找到相应结点")
            break
        }
        HT[s1].parent = i
        HT[s2].parent = i
        HT[i] = HTNode(r'0', HT[s1].weight + HT[s2].weight, 0, s1, s2)
    }

    return HT
}
// 私有函数，选择两个最小权重且无父节点的节点
private func _selectMinNodes(HT: Array<HTNode>, range: Range<Int64>): (Int64, Int64) {
    var min1Weight = 1000000
    var min2Weight = 1000000
    var min1Index: Int64 = -1
    var min2Index: Int64 = -1
    for (i in range) {
        let node = HT[i]
        if (node.parent == 0) {
            if (node.weight < min1Weight) {
                min2Weight = min1Weight
                min2Index = min1Index
                min1Weight = node.weight
                min1Index = i
            } else if (node.weight < min2Weight) {
                min2Weight = node.weight
                min2Index = i
            }
        }
    }
    return (min1Index, min2Index)
}

//将内容写入文件之中
public func writeHuffmanCodesToFile(HT: Array<HTNode>, codes: Array<String>, n: Int64) {
    // let filename = "${prefixFilename}_tree_${treeSequenceNumber}.txt"
    let filename = "Tree_${treeSequenceNumber}.txt"
    var content = ""
    for (i in 1..(n + 1)) {
        let char = HT[i].data
        let code = HT[i].weight // codes[i - 1]
        content += "${char}" + " " + "${code}\n"
    }
    try (secretStoreFile = File.create(filename), contentWriter = StringWriter(secretStoreFile)) {
        contentWriter.write(content)
    }
    println("哈夫曼编码表及权值已写入文件: ${filename}")
}
// 使用哈夫曼编码对消息进行编码
func encodeMessage(message: String, HT: Array<HTNode>, codes: Array<String>, n: Int64): String {
    var encodedMessage = ""
    let defaultCode = codes[n - 1]
    for (char in message) {
        var found = false
        for (j in 1..=n) {
            if (HT[j].data == Rune(char)) {
                encodedMessage += codes[j - 1]
                found = true
                break
            }
        }
        if (!found) {
            encodedMessage += defaultCode
            println("未找到字符 ${char}，使用默认编码")
        }
    }
    return encodedMessage
}

// 使用哈夫曼树解码编码字符串
public func huffmanDecoding(encodedStr: String, HT: Array<HTNode>, n: Int64): String {
    var result = ""
    let m = 2 * n - 1
    var currentIndex = m
    for (bit in encodedStr) {
        if (Rune(bit) == r'0') {
            currentIndex = HT[currentIndex].lchild
        } else if (Rune(bit) == r'1') {
            currentIndex = HT[currentIndex].rchild
        } else {
            println("遇到无效字符，解码失败")
            return ""
        }
        if (HT[currentIndex].lchild == 0 && HT[currentIndex].rchild == 0) {
            result += String(HT[currentIndex].data)
            currentIndex = m
        }
    }
    return result
}
// 对文件中的字符及对应权值进行编码译码
func buildAndUseHuffmanTree(hash: HashMap<Rune, Int64>, s: String) {
    // 转换数据结构
    let charData = convertHashToData(hash)
    let n = Int64(charData.size)

    //  构建哈夫曼树
    let huffmanTree = createHuffmanTree(charData, n)

    // 生成编码表
    let codes = huffmanCoding(huffmanTree, n)

    let decodedStr = huffmanDecoding(s, huffmanTree, n)
    println("解码结果: ${decodedStr}")
}
// 基于哈夫曼树生成哈夫曼编码
func huffmanCoding(HT: Array<HTNode>, n: Int64): Array<String> {
    var codes = Array<String>(n, item: "")
    for (i in 1..=n) {
        var current = i
        var code = ""
        var parent = HT[i].parent
        while (parent != 0) {
            if (HT[parent].lchild == current) {
                code = "0" + code
            } else {
                code = "1" + code
            }
            current = parent
            parent = HT[current].parent
        }
        codes[i - 1] = code
    }
    return codes
}
func createHuffmanTreeFromString(message: String): (Array<HTNode>, Array<String>, Int64) {
    let characterData = calculateCharacterFrequencies(message)
    let n = Int64(characterData.size)
    let huffmanTree = createHuffmanTree(characterData, n)
    let codes = huffmanCoding(huffmanTree, n)
    return (huffmanTree, codes, n)
}