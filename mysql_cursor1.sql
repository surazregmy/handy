DELIMITER $$

USE `*******`$$

DROP PROCEDURE IF EXISTS `move_authorization_history_to_shardINDEX`$$

CREATE DEFINER=`*****`@`%` PROCEDURE `move_authorization_history_to_shardINDEX`()
BEGIN

  DECLARE cur_finished   INTEGER DEFAULT 0;
  DECLARE client_name   VARCHAR(255) DEFAULT '';

  DECLARE client_cursor CURSOR FOR
    SELECT distinct client from authorization_history;

  DECLARE CONTINUE HANDLER FOR NOT FOUND
    SET cur_finished = 1;

  OPEN  client_cursor;

  get_client : LOOP
      FETCH client_cursor INTO client_name;
      IF cur_finished = 1 THEN
        LEAVE get_client;
      end if;
      SET @dclient = client_name;
      SELECT @shard_query :=  `shard` into @indexshard1 FROM shardINDEX.customer where customer_host_name = @dclient;
      #SELECT @dclient,@shard_query,@indexshard1;
      #check if the table exists
      SELECT  IF( EXISTS(
                    SELECT * FROM INFORMATION_SCHEMA.TABLES
                    WHERE TABLE_SCHEMA= @indexshard1 AND TABLE_NAME='authorization_history'), 1, 0) into @tablepresence;
      IF @tablepresence = 0 THEN
        SET @rows_affected = 0;
        SET @createtablequery = concat("CREATE TABLE ",@indexshard1,".`authorization_history` (
                                    `id` bigint(20) NOT NULL AUTO_INCREMENT,
                                    `version` bigint(20) NOT NULL,
                                    `authorization_id` varchar(255) DEFAULT NULL,
                                    `client` varchar(255) DEFAULT NULL,
                                    `last_updated` datetime NOT NULL,
                                    `reopened_by` bigint(20) DEFAULT NULL,
                                    `status` varchar(255) DEFAULT NULL,
                                    PRIMARY KEY (`id`)
                                  ) ENGINE=InnoDB AUTO_INCREMENT=868376 DEFAULT CHARSET=latin1");
        CALL shardINDEX.executeStatement(@createtablequery,@rows_affected);
        SET @insert_query = concat("insert into ",@indexshard1,".`authorization_history`(
                                    SELECT * from shardINDEX.authorization_history where client ='",@dclient,"');");
        CALL shardINDEX.executeStatement(@insert_query,@rows_affected);
      end if;

      IF @tablepresence = 1 THEN
        SET @insert_query = concat("insert into ",@indexshard1,".`authorization_history`(
                                    SELECT * from shardINDEX.authorization_history where client ='",@dclient,"');");
        CALL shardINDEX.executeStatement(@insert_query,@rows_affected);
      end if;
  end loop get_client;

END$$
DELIMITER



