-- 创建路由规则表
create table route_rule
(
  id int primary key auto_increment,
  rule_type varchar(16) not null,
  rules_str varchar(1024) not null,
  priority int default 1,
  status varchar(16) default 'CLOSED',
  create_time date,
  update_time date
)