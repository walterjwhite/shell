package com.walterjwhite.shell.api.service;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;

public interface ShellCommandService<EntityType extends AbstractEntity> {
  EntityType execute(EntityType entityType) throws Exception;
}
