/**
 * admin请求url
 *
 * @type {string}
 */
var ADMIN_URL = "http://192.168.171.135:8080/admin";

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
 * 加载规则数据
 *
 * @param loadSuccess 加载数据成功后回调方法
 */
function loadRouteRules(loadSuccess) {
    $.getJSON(ADMIN_URL, {
            command: 'QUERY',
            type: 'ALL'
        },
        function (result) {
            if (result.success) {
                loadSuccess(result.data)
            }
        }
    );
}