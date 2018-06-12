/**
 * admin请求url
 *
 * @type {string}
 */
var ADMIN_URL = "http://172.30.251.33:8099/admin";

/**
 * 字符串buffer类
 *
 * @constructor
 */
function StringBuffer() {
    this.__strings__ = new Array();
}

StringBuffer.prototype.append = function (str) {
    this.__strings__.push(str);
    return this;    //方便链式操作
}
StringBuffer.prototype.toString = function () {
    return this.__strings__.join("");
}

/**
 * 判断字符串末尾匹配
 *
 * @param endStr
 * @returns {boolean}
 */
String.prototype.endWith = function (endStr) {
    var d = this.length - endStr.length;
    return (d >= 0 && this.lastIndexOf(endStr) == d)
}