CREATE DATABASE IF NOT EXISTS `police_population_db` 
CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE `police_population_db`;

-- ========================================
-- 人口数据库管理系统 - 完整建表脚本
-- 严格符合《Java开发手册（黄山版）》规约
-- 项目负责人：纪子昂
-- 日期：2026-06-22
-- ========================================

-- 1. t_user 用户信息表
CREATE TABLE `t_user` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` varchar(25) NOT NULL COMMENT '用户唯一标识ID',
  `user_name` varchar(50) NOT NULL COMMENT '用户姓名',
  `passwd` varchar(128) NOT NULL COMMENT '加密存储的登录密码',
  `phone` varchar(11) NOT NULL COMMENT '手机号',
  `id_card` varchar(18) NOT NULL COMMENT '身份证号',
  `role` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '角色：0-系统管理员 1-户籍工作人员 2-审核人员 3-网格员/民警',
  `state` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '状态：0-离线 1-在线 2-已锁定',
  `retry_count` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '连续登录失败次数',
  `last_login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
  `last_login_ip` varchar(45) DEFAULT NULL COMMENT '最后登录IP地址',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '账号创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除：0-正常 1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`),
  UNIQUE KEY `uk_id_card` (`id_card`),
  INDEX `idx_user_name` (`user_name`),
  INDEX `idx_role_state` (`role`, `state`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户信息表';

-- 2. t_role_perm 角色权限表
CREATE TABLE `t_role_perm` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `perm_id` varchar(25) NOT NULL COMMENT '权限记录唯一ID',
  `role` tinyint unsigned NOT NULL COMMENT '角色编号：0-管理员 1-工作人员 2-审核 3-网格员',
  `menu_list` text COMMENT '菜单权限JSON字符串',
  `func_list` text COMMENT '功能操作权限JSON字符串',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_perm_id` (`perm_id`),
  INDEX `idx_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色权限表';

-- 3. t_household 家庭户口档案表
CREATE TABLE `t_household` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `hukou_no` varchar(20) NOT NULL COMMENT '户口编号（唯一）',
  `apply_no` varchar(25) NOT NULL COMMENT '立户申请单号（唯一）',
  `householder_name` varchar(50) NOT NULL COMMENT '户主姓名',
  `householder_id` varchar(18) NOT NULL COMMENT '户主身份证号',
  `address` varchar(500) NOT NULL COMMENT '户籍地址',
  `phone` varchar(11) DEFAULT NULL COMMENT '户主联系电话',
  `reason` varchar(500) DEFAULT NULL COMMENT '立户原因',
  `apply_date` datetime NOT NULL COMMENT '申请日期',
  `operator_id` varchar(25) NOT NULL COMMENT '经办人ID',
  `auditor_id` varchar(25) DEFAULT NULL COMMENT '审核人ID',
  `status` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '状态：0-待审核 1-已立户 2-驳回 3-已注销',
  `reject_reason` varchar(500) DEFAULT NULL COMMENT '驳回原因',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_hukou_no` (`hukou_no`),
  UNIQUE KEY `uk_apply_no` (`apply_no`),
  INDEX `idx_householder_id` (`householder_id`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='家庭户口档案表';

-- 4. t_household_member 家庭成员表
CREATE TABLE `t_household_member` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `member_id` varchar(25) NOT NULL COMMENT '成员记录唯一ID',
  `hukou_no` varchar(20) NOT NULL COMMENT '所属户口编号',
  `id_card` varchar(18) NOT NULL COMMENT '成员身份证号',
  `name` varchar(50) NOT NULL COMMENT '成员姓名',
  `gender` tinyint unsigned NOT NULL COMMENT '性别：0-男 1-女',
  `birth_date` date NOT NULL COMMENT '出生日期',
  `relation` varchar(20) NOT NULL COMMENT '与户主关系',
  `phone` varchar(11) DEFAULT NULL COMMENT '联系电话',
  `occupation` varchar(50) DEFAULT NULL COMMENT '职业',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '录入时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_member_id` (`member_id`),
  INDEX `idx_hukou_no` (`hukou_no`),
  INDEX `idx_id_card` (`id_card`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='家庭成员表';

-- 5. t_household_log 户口操作日志表
CREATE TABLE `t_household_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `log_id` varchar(25) NOT NULL COMMENT '日志唯一ID',
  `hukou_no` varchar(20) NOT NULL COMMENT '关联户口编号',
  `op_type` tinyint unsigned NOT NULL COMMENT '操作类型：3-新增 4-修改 5-审批 6-撤销 8-归档',
  `operator_id` varchar(25) NOT NULL COMMENT '操作人ID',
  `op_content` varchar(500) DEFAULT NULL COMMENT '操作内容描述',
  `op_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  INDEX `idx_hukou_no` (`hukou_no`),
  INDEX `idx_op_type` (`op_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='户口操作日志表';

-- 6. t_resident 常住人口信息表
CREATE TABLE `t_resident` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `id_card` varchar(18) NOT NULL COMMENT '身份证号（唯一标识）',
  `resident_no` varchar(25) NOT NULL COMMENT '人员编号',
  `name` varchar(50) NOT NULL COMMENT '姓名',
  `gender` tinyint unsigned NOT NULL COMMENT '性别：0-男 1-女',
  `birth_date` date DEFAULT NULL COMMENT '出生日期',
  `nation` varchar(20) DEFAULT NULL COMMENT '民族',
  `hukou_no` varchar(20) DEFAULT NULL COMMENT '所属户口编号',
  `area` varchar(50) NOT NULL COMMENT '户籍归属片区',
  `address` varchar(500) DEFAULT NULL COMMENT '现住地址',
  `native_place` varchar(500) DEFAULT NULL COMMENT '籍贯',
  `marital_status` tinyint unsigned DEFAULT NULL COMMENT '婚姻状况：0-未婚 1-已婚 2-离异 3-丧偶',
  `education` varchar(20) DEFAULT NULL COMMENT '文化程度',
  `occupation` varchar(50) DEFAULT NULL COMMENT '职业',
  `work_unit` varchar(100) DEFAULT NULL COMMENT '工作单位',
  `phone` varchar(11) DEFAULT NULL COMMENT '联系电话',
  `hukou_type` tinyint unsigned DEFAULT NULL COMMENT '户口类型：0-农业 1-非农业',
  `status` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '状态：0-在册 1-已迁出 2-已归档',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '录入时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_id_card` (`id_card`),
  UNIQUE KEY `uk_resident_no` (`resident_no`),
  INDEX `idx_hukou_no` (`hukou_no`),
  INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='常住人口信息表';

-- 7. t_resident_change_log 常住人口变更记录表
CREATE TABLE `t_resident_change_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `change_id` varchar(25) NOT NULL COMMENT '变更记录唯一ID',
  `id_card` varchar(18) NOT NULL COMMENT '关联人员身份证号',
  `field_name` varchar(50) NOT NULL COMMENT '变更字段名称',
  `old_value` varchar(200) DEFAULT NULL COMMENT '变更前值',
  `new_value` varchar(200) DEFAULT NULL COMMENT '变更后值',
  `change_reason` varchar(500) NOT NULL COMMENT '变更原因',
  `operator_id` varchar(25) NOT NULL COMMENT '操作人ID',
  `change_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '变更时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  INDEX `idx_id_card` (`id_card`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='常住人口变更记录表';

-- 8. t_move_in 户口迁入申请表
CREATE TABLE `t_move_in` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `apply_no` varchar(25) NOT NULL COMMENT '迁入申请单号（唯一）',
  `name` varchar(50) NOT NULL COMMENT '迁入人员姓名',
  `id_card` varchar(18) NOT NULL COMMENT '迁入人员身份证号',
  `origin_address` varchar(500) NOT NULL COMMENT '原户籍地址',
  `target_address` varchar(500) NOT NULL COMMENT '现落户地址',
  `reason` varchar(500) DEFAULT NULL COMMENT '迁入原因',
  `voucher_no` varchar(25) NOT NULL COMMENT '迁入凭证编号',
  `operator_id` varchar(25) NOT NULL COMMENT '经办人ID',
  `status` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '状态：0-一级审批中 1-二级审批中 2-三级审批中 3-通过 4-驳回 5-已撤销',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请提交时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_apply_no` (`apply_no`),
  UNIQUE KEY `uk_id_card` (`id_card`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='户口迁入申请表';

-- 9. t_move_in_approval 迁入多级审批记录表
CREATE TABLE `t_move_in_approval` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `approval_id` varchar(25) NOT NULL COMMENT '审批记录唯一ID',
  `apply_no` varchar(25) NOT NULL COMMENT '关联申请单号',
  `level` tinyint unsigned NOT NULL COMMENT '审批层级：1-一级 2-二级 3-三级',
  `approver_id` varchar(25) NOT NULL COMMENT '审批人ID',
  `result` tinyint unsigned NOT NULL COMMENT '审批结果：1-通过 0-驳回',
  `opinion` varchar(500) DEFAULT NULL COMMENT '审批意见',
  `approval_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '审批时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  INDEX `idx_apply_no` (`apply_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='迁入多级审批记录表';

-- 10. t_move_in_material 迁入证明材料表
CREATE TABLE `t_move_in_material` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `material_id` varchar(25) NOT NULL COMMENT '材料记录唯一ID',
  `apply_no` varchar(25) NOT NULL COMMENT '关联申请单号',
  `material_name` varchar(100) NOT NULL COMMENT '材料名称',
  `material_no` varchar(25) DEFAULT NULL COMMENT '材料编号',
  `file_path` varchar(255) DEFAULT NULL COMMENT '电子附件存储路径',
  `verify_status` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '核验状态：0-待核验 1-通过 2-不通过',
  `verifier_id` varchar(25) DEFAULT NULL COMMENT '核验人ID',
  `verify_time` datetime DEFAULT NULL COMMENT '核验时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  INDEX `idx_apply_no` (`apply_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='迁入证明材料表';

-- 11. t_move_out 户口迁出申请表
CREATE TABLE `t_move_out` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `apply_no` varchar(25) NOT NULL COMMENT '迁出申请单号（唯一）',
  `id_card` varchar(18) NOT NULL COMMENT '迁出人身份证号',
  `name` varchar(50) NOT NULL COMMENT '迁出人姓名',
  `target_address` varchar(500) NOT NULL COMMENT '目标迁入地址',
  `reason` varchar(500) DEFAULT NULL COMMENT '迁出原因',
  `voucher_no` varchar(25) NOT NULL COMMENT '迁出凭证编号',
  `operator_id` varchar(25) NOT NULL COMMENT '经办人ID',
  `status` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '状态：0-一级审批中 1-二级审批中 2-三级审批中 3-通过 4-驳回 5-已撤销',
  `reject_reason` varchar(500) DEFAULT NULL COMMENT '驳回原因',
  `auditor_id` varchar(25) DEFAULT NULL COMMENT '审核人ID',
  `audit_time` datetime DEFAULT NULL COMMENT '审核时间',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '申请提交时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后更新时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_apply_no` (`apply_no`),
  UNIQUE KEY `uk_id_card` (`id_card`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='户口迁出申请表';

-- 12. t_move_out_approval 迁出多级审批记录表
CREATE TABLE `t_move_out_approval` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `approval_id` varchar(25) NOT NULL COMMENT '审批记录唯一ID',
  `apply_no` varchar(25) NOT NULL COMMENT '关联申请单号',
  `level` tinyint unsigned NOT NULL COMMENT '审批层级：1-一级 2-二级 3-三级',
  `approver_id` varchar(25) NOT NULL COMMENT '审批人ID',
  `result` tinyint unsigned NOT NULL COMMENT '审批结果：1-通过 0-驳回',
  `opinion` varchar(500) DEFAULT NULL COMMENT '审批意见',
  `approval_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '审批时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  INDEX `idx_apply_no` (`apply_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='迁出多级审批记录表';

-- 13. t_move_out_archive 迁出档案留存表
CREATE TABLE `t_move_out_archive` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `archive_id` varchar(25) NOT NULL COMMENT '档案唯一ID',
  `apply_no` varchar(25) NOT NULL COMMENT '关联申请单号',
  `id_card` varchar(18) NOT NULL COMMENT '迁出人身份证号',
  `name` varchar(50) NOT NULL COMMENT '迁出人姓名',
  `target_address` varchar(500) NOT NULL COMMENT '目标迁入地址',
  `move_out_time` datetime NOT NULL COMMENT '迁出时间',
  `operator_id` varchar(25) NOT NULL COMMENT '经办人ID',
  `is_exported` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '导出标记：0-未导出 1-已导出',
  `archive_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '台账归档时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_archive_id` (`archive_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='迁出档案留存表';

-- 14. t_floating_pop 流动人口登记表
CREATE TABLE `t_floating_pop` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `record_id` varchar(25) NOT NULL COMMENT '记录唯一ID',
  `name` varchar(50) NOT NULL COMMENT '流动人员姓名',
  `id_card` varchar(18) NOT NULL COMMENT '身份证号',
  `gender` tinyint unsigned NOT NULL COMMENT '性别',
  `temp_address` varchar(500) NOT NULL COMMENT '暂住地址',
  `area` varchar(50) NOT NULL COMMENT '所属片区',
  `start_date` date NOT NULL COMMENT '暂住起始时间',
  `stay_duration` int unsigned NOT NULL COMMENT '计划停留时长（天）',
  `expected_end_date` date NOT NULL COMMENT '预计到期日',
  `work_unit` varchar(100) DEFAULT NULL COMMENT '工作单位',
  `emergency_contact` varchar(50) DEFAULT NULL COMMENT '紧急联系人',
  `emergency_phone` varchar(11) DEFAULT NULL COMMENT '紧急联系电话',
  `status` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '状态：0-暂住中 1-已到期 2-已注销',
  `cancel_time` datetime DEFAULT NULL COMMENT '注销办理时间',
  `destination` varchar(500) DEFAULT NULL COMMENT '离开后去向',
  `cancel_operator_id` varchar(25) DEFAULT NULL COMMENT '注销经办人ID',
  `operator_id` varchar(25) NOT NULL COMMENT '登记经办人ID',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登记时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_record_id` (`record_id`),
  UNIQUE KEY `uk_id_card` (`id_card`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='流动人口登记表';

-- 15. t_float_change_log 流动人口变更记录表
CREATE TABLE `t_float_change_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `change_id` varchar(25) NOT NULL COMMENT '变更记录唯一ID',
  `record_id` varchar(25) NOT NULL COMMENT '关联流动人口记录ID',
  `field_name` varchar(50) NOT NULL COMMENT '变更字段',
  `old_value` varchar(200) DEFAULT NULL COMMENT '变更前内容',
  `new_value` varchar(200) DEFAULT NULL COMMENT '变更后内容',
  `operator_id` varchar(25) NOT NULL COMMENT '变更操作人ID',
  `change_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '变更时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  INDEX `idx_record_id` (`record_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='流动人口变更记录表';

-- 16. t_key_person 重点人口档案表
CREATE TABLE `t_key_person` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `archive_id` varchar(25) NOT NULL COMMENT '档案唯一ID',
  `name` varchar(50) NOT NULL COMMENT '姓名',
  `gender` tinyint unsigned NOT NULL COMMENT '性别',
  `birth_date` date NOT NULL COMMENT '出生日期',
  `id_card` varchar(18) NOT NULL COMMENT '身份证号',
  `address` varchar(500) NOT NULL COMMENT '户籍地址',
  `current_address` varchar(500) DEFAULT NULL COMMENT '现居地址',
  `key_type` tinyint unsigned NOT NULL COMMENT '重点关注类型',
  `key_reason` varchar(500) NOT NULL COMMENT '关注原因',
  `control_level` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '管控等级：0-普通 1-中等 2-重点',
  `grid_officer` varchar(50) DEFAULT NULL COMMENT '负责网格员',
  `police_officer` varchar(50) DEFAULT NULL COMMENT '负责民警',
  `officer_phone` varchar(11) DEFAULT NULL COMMENT '负责人员联系电话',
  `status` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '状态：0-管控中 1-已解除',
  `operator_id` varchar(25) NOT NULL COMMENT '建档操作人ID',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '建档时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_archive_id` (`archive_id`),
  UNIQUE KEY `uk_id_card` (`id_card`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='重点人口档案表';

-- 17. t_key_person_track 重点人口动态跟踪记录表
CREATE TABLE `t_key_person_track` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `track_id` varchar(25) NOT NULL COMMENT '跟踪记录唯一ID',
  `archive_id` varchar(25) NOT NULL COMMENT '关联重点人口档案ID',
  `track_type` tinyint unsigned NOT NULL COMMENT '跟踪类型：0-走访 1-近况 2-状态变更',
  `content` varchar(500) NOT NULL COMMENT '跟踪内容',
  `operator_id` varchar(25) NOT NULL COMMENT '记录操作人ID',
  `track_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '跟踪时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  INDEX `idx_archive_id` (`archive_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='重点人口动态跟踪记录表';

-- 18. t_key_status_change 重点人口管控状态变更表
CREATE TABLE `t_key_status_change` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `change_id` varchar(25) NOT NULL COMMENT '变更记录唯一ID',
  `archive_id` varchar(25) NOT NULL COMMENT '关联重点人口档案ID',
  `old_level` tinyint unsigned NOT NULL COMMENT '原管控等级',
  `new_level` tinyint unsigned NOT NULL COMMENT '新管控等级',
  `change_reason` varchar(500) NOT NULL COMMENT '变更原因',
  `operator_id` varchar(25) NOT NULL COMMENT '操作人ID',
  `change_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '变更时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  INDEX `idx_archive_id` (`archive_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='重点人口管控状态变更表';

-- 19. t_key_alert 重点人口预警记录表
CREATE TABLE `t_key_alert` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `alert_id` varchar(25) NOT NULL COMMENT '预警记录唯一ID',
  `archive_id` varchar(25) NOT NULL COMMENT '关联重点人口档案ID',
  `alert_type` tinyint unsigned NOT NULL COMMENT '预警类型：0-超期未回访 1-状态异常',
  `alert_content` varchar(500) NOT NULL COMMENT '预警内容',
  `is_resolved` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '是否已处理：0-未处理 1-已处理',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '预警生成时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  INDEX `idx_archive_id` (`archive_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='重点人口预警记录表';

-- 20. t_certificate 证件信息表
CREATE TABLE `t_certificate` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `cert_no` varchar(25) NOT NULL COMMENT '证件编号（全局唯一）',
  `holder_id_card` varchar(18) NOT NULL COMMENT '持证人身份证号',
  `holder_name` varchar(50) NOT NULL COMMENT '持证人姓名',
  `cert_type` tinyint unsigned NOT NULL COMMENT '证件类型：0-身份证 1-户口本 2-户籍证明',
  `status` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '证件状态：0-正常 1-已挂失 2-补办中 3-已作废 4-已领取',
  `issue_date` date NOT NULL COMMENT '发证日期',
  `expire_date` date DEFAULT NULL COMMENT '有效截止日',
  `is_received` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '是否已领取',
  `business_remark` varchar(500) DEFAULT NULL COMMENT '业务备注',
  `operator_id` varchar(25) NOT NULL COMMENT '办理操作人ID',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登记办理时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cert_no` (`cert_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='证件信息表';

-- 21. t_cert_loss 证件挂失补办记录表
CREATE TABLE `t_cert_loss` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `loss_id` varchar(25) NOT NULL COMMENT '挂失记录唯一ID',
  `old_cert_no` varchar(25) NOT NULL COMMENT '原证件编号',
  `new_cert_no` varchar(25) NOT NULL COMMENT '补办新证件编号',
  `loss_reason` varchar(500) NOT NULL COMMENT '挂失原因',
  `progress` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '补办进度：0-已挂失 1-补办中 2-已办结',
  `operator_id` varchar(25) NOT NULL COMMENT '经办人ID',
  `loss_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '挂失登记时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_loss_id` (`loss_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='证件挂失补办记录表';

-- 22. t_cert_cancel 证件作废记录表
CREATE TABLE `t_cert_cancel` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `cancel_id` varchar(25) NOT NULL COMMENT '作废记录唯一ID',
  `cert_no` varchar(25) NOT NULL COMMENT '作废证件编号',
  `reason` varchar(500) NOT NULL COMMENT '作废原因',
  `operator_id` varchar(25) NOT NULL COMMENT '操作人ID',
  `cancel_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作废时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_cancel_id` (`cancel_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='证件作废记录表';

-- 23. t_op_log 系统操作日志表
CREATE TABLE `t_op_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `log_id` varchar(25) NOT NULL COMMENT '日志唯一ID',
  `operator_id` varchar(25) NOT NULL COMMENT '操作账号ID',
  `op_type` tinyint unsigned NOT NULL COMMENT '操作类型：1-登录 2-登出 3-新增...',
  `module_name` varchar(50) NOT NULL COMMENT '操作模块名称',
  `op_content` varchar(500) NOT NULL COMMENT '操作内容描述',
  `op_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  `op_ip` varchar(45) DEFAULT NULL COMMENT '操作IP地址',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  INDEX `idx_operator_id` (`operator_id`),
  INDEX `idx_op_type` (`op_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统操作日志表';

-- 24. t_notification 消息提醒表
CREATE TABLE `t_notification` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `notif_id` varchar(25) NOT NULL COMMENT '消息唯一ID',
  `target_user_id` varchar(25) NOT NULL COMMENT '目标接收用户ID',
  `notif_type` tinyint unsigned NOT NULL COMMENT '消息类型：0-业务待审 1-证件到期...',
  `title` varchar(100) NOT NULL COMMENT '消息标题',
  `content` varchar(500) NOT NULL COMMENT '消息内容',
  `is_read` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '是否已读：0-未读 1-已读',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '消息生成时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  INDEX `idx_target_user_id` (`target_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息提醒表';

-- 25. t_backup_log 数据备份日志表
CREATE TABLE `t_backup_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `backup_id` varchar(25) NOT NULL COMMENT '备份记录唯一ID',
  `backup_type` tinyint unsigned NOT NULL COMMENT '备份类型：0-手动 1-自动',
  `file_name` varchar(255) NOT NULL COMMENT '备份文件名',
  `file_size` int unsigned NOT NULL COMMENT '备份文件大小（KB）',
  `operator_id` varchar(25) NOT NULL COMMENT '操作人ID',
  `backup_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '备份时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_backup_id` (`backup_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='数据备份日志表';

-- 26. t_scheduled_task 定时任务配置表
CREATE TABLE `t_scheduled_task` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `task_id` varchar(25) NOT NULL COMMENT '任务唯一ID',
  `task_name` varchar(50) NOT NULL COMMENT '任务名称',
  `task_type` tinyint unsigned NOT NULL COMMENT '任务类型：0-暂住到期提醒 ...',
  `cron_expr` varchar(100) NOT NULL COMMENT 'Cron表达式',
  `is_active` tinyint unsigned NOT NULL DEFAULT 1 COMMENT '是否启用：0-停用 1-启用',
  `gmt_create` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_task_id` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='定时任务配置表';

-- 27. t_task_exec_log 定时任务执行日志表
CREATE TABLE `t_task_exec_log` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `exec_id` varchar(25) NOT NULL COMMENT '执行记录唯一ID',
  `task_id` varchar(25) NOT NULL COMMENT '关联任务ID',
  `exec_status` tinyint unsigned NOT NULL COMMENT '执行状态',
  `exec_result` varchar(500) DEFAULT NULL COMMENT '执行结果',
  `start_time` datetime NOT NULL COMMENT '开始时间',
  `end_time` datetime DEFAULT NULL COMMENT '结束时间',
  `is_deleted` tinyint unsigned NOT NULL DEFAULT 0 COMMENT '逻辑删除',
  PRIMARY KEY (`id`),
  INDEX `idx_task_id` (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='定时任务执行日志表';

-- 验证命令
-- SHOW TABLES;
-- SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'police_population_db';
