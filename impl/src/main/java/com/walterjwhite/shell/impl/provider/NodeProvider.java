package com.walterjwhite.shell.impl.provider;

import com.walterjwhite.datastore.api.repository.Repository;
import com.walterjwhite.infrastructure.inject.core.NodeId;
import com.walterjwhite.property.impl.annotation.Property;
import com.walterjwhite.shell.api.model.Node;
import com.walterjwhite.shell.impl.query.FindNodeByUUIDQuery;
import javax.inject.Inject;
import javax.inject.Provider;
import javax.inject.Singleton;

@Singleton
public class NodeProvider implements Provider<Node> {
  // set from the command-line on start-up
  protected final String nodeId;
  protected final Node node;

  protected final Provider<Repository> repositoryProvider;

  @Inject
  public NodeProvider(
      @Property(NodeId.class) String nodeId, Provider<Repository> repositoryProvider) {
    super();

    this.nodeId = nodeId;
    this.repositoryProvider = repositoryProvider;

    this.node = getNode();
  }

  protected Node getNode() {
    return repositoryProvider.get().query(new FindNodeByUUIDQuery(nodeId));
  }

  //  @Singleton
  @Override
  public Node get() {
    //    repositoryProvider.get().refresh(node);
    return node;
  }
}
