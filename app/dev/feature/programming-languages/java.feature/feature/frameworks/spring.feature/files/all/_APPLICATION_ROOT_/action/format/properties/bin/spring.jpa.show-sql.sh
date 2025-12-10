_DETAIL "Preventing Hibernate from logging to stdout"


for _JAVA_SPRING_JPA_LOGGING_FILE in $(grep -l ^spring.jpa.show-sql=true $@); do
	$_CONF_GNU_SED -i 's/^spring.jpa.show-sql=true/#spring.jpa.show-sql=true/' $_JAVA_SPRING_JPA_LOGGING_FILE
	$_CONF_GNU_SED -i 's/^spring.jpa.properties.hibernate.format_sql=true/#spring.jpa.properties.hibernate.format_sql=true/' $_JAVA_SPRING_JPA_LOGGING_FILE

	$_CONF_GNU_SED -i '/#spring.jpa.show-sql=true/a logging.level.org.hibernate.SQL=DEBUG' $_JAVA_SPRING_JPA_LOGGING_FILE
	$_CONF_GNU_SED -i '/#spring.jpa.show-sql=true/a logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE' $_JAVA_SPRING_JPA_LOGGING_FILE

	$_CONF_GNU_SED -i '/#spring.jpa.show-sql=true/a logging.level.org.springframework.jdbc.core.JdbcTemplate=DEBUG' $_JAVA_SPRING_JPA_LOGGING_FILE
	$_CONF_GNU_SED -i '/#spring.jpa.show-sql=true/a logging.level.org.springframework.jdbc.core.StatementCreatorUtils=TRACE' $_JAVA_SPRING_JPA_LOGGING_FILE
done
