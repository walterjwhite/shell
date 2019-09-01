package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractNamedEntity;
import javax.persistence.Entity;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@ToString(doNotUseGetters = true)
// @PersistenceCapable
@NoArgsConstructor
@Entity
public class Service extends AbstractNamedEntity {
  public Service(String name) {
    super(name);
  }
}
