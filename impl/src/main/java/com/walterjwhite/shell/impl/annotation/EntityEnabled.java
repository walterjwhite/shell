package com.walterjwhite.shell.impl.annotation;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import javax.transaction.Transactional;

@Transactional
@Target({ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
public @interface EntityEnabled {}
