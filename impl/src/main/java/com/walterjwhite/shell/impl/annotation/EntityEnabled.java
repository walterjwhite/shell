package com.walterjwhite.shell.impl.annotation;

import com.google.inject.persist.Transactional;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Transactional
@Target({ElementType.METHOD})
@Retention(RetentionPolicy.RUNTIME)
public @interface EntityEnabled {}
