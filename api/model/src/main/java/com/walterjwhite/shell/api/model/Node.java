package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import javax.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@AllArgsConstructor
@NoArgsConstructor
@Data
@ToString(doNotUseGetters = true)
// @PersistenceCapable
@Entity
public class Node extends AbstractEntity {
  @Column(unique = true, nullable = false, updatable = false)
  protected String uuid;
}
