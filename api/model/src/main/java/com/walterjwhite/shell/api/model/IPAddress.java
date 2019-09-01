package com.walterjwhite.shell.api.model;

import com.walterjwhite.datastore.api.model.entity.AbstractEntity;
import javax.persistence.Column;
import javax.persistence.Entity;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

@Data
@ToString(doNotUseGetters = true)
@AllArgsConstructor
@NoArgsConstructor
// @PersistenceCapable
@Entity
public class IPAddress extends AbstractEntity {
  @Column(nullable = false, unique = true, updatable = false)
  protected String address;
}
