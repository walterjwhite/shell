log_detail "preventing Hibernate from logging to stdout"


for _JAVA_SPRING_JPA_LOGGING_FILE in $(_extension_find_default -exec grep -l ^spring.jpa.show-sql=true {} +); do
  $GNU_SED -i 's/^spring.jpa.show-sql=true/#spring.jpa.show-sql=true/' $_JAVA_SPRING_JPA_LOGGING_FILE
  $GNU_SED -i 's/^spring.jpa.properties.hibernate.format_sql=true/#spring.jpa.properties.hibernate.format_sql=true/' $_JAVA_SPRING_JPA_LOGGING_FILE

  $GNU_SED -i '/#spring.jpa.show-sql=true/a logging.level.org.hibernate.SQL=DEBUG' $_JAVA_SPRING_JPA_LOGGING_FILE
  $GNU_SED -i '/#spring.jpa.show-sql=true/a logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE' $_JAVA_SPRING_JPA_LOGGING_FILE

  $GNU_SED -i '/#spring.jpa.show-sql=true/a logging.level.org.springframework.jdbc.core.JdbcTemplate=DEBUG' $_JAVA_SPRING_JPA_LOGGING_FILE
  $GNU_SED -i '/#spring.jpa.show-sql=true/a logging.level.org.springframework.jdbc.core.StatementCreatorUtils=TRACE' $_JAVA_SPRING_JPA_LOGGING_FILE
done
