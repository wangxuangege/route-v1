/**
 * admin请求url
 *
 * @type {string}
 */
var ADMIN_URL = "http://192.168.171.131:8080/admin";

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
