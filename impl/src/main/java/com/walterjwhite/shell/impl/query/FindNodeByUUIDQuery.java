package com.walterjwhite.shell.impl.query;

import com.walterjwhite.datastore.query.AbstractSingularQuery;
import com.walterjwhite.shell.api.model.Node;
import lombok.Getter;
import lombok.ToString;

@ToString(doNotUseGetters = true)
@Getter
public class FindNodeByUUIDQuery extends AbstractSingularQuery<Node> {
  protected final String uuid;

  public FindNodeByUUIDQuery(String uuid) {
    super(Node.class, true);
    this.uuid = uuid;
  }
}
