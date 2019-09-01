package com.walterjwhite.shell.api.model;

import javax.persistence.Entity;
import lombok.*;

@ToString(doNotUseGetters = true, callSuper = true)
@EqualsAndHashCode(callSuper = true)
@Data
@AllArgsConstructor
@NoArgsConstructor
// @PersistenceCapable
@Entity
public class FreeBSDJailShellCommand extends ChrootShellCommand implements Chrootable {
  protected String jailName;
}
