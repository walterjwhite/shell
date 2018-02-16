package com.walterjwhite.shell.impl.provider;

import com.google.inject.persist.Transactional;
import com.walterjwhite.google.guice.property.property.Property;
import com.walterjwhite.shell.api.model.Node;
import com.walterjwhite.shell.api.property.NodeId;
import com.walterjwhite.shell.api.repository.NodeRepository;
import javax.inject.Inject;
import javax.inject.Provider;
import javax.inject.Singleton;
import javax.persistence.NoResultException;

@Singleton
public class NodeProvider implements Provider<Node> {
  // set from the command-line on start-up
  protected final String nodeId;
  protected final Node node;

  protected final Provider<NodeRepository> nodeRepositoryProvider;

  @Inject
  public NodeProvider(
      @Property(NodeId.class) String nodeId, Provider<NodeRepository> nodeRepositoryProvider) {
    super();

    this.nodeId = nodeId;
    this.nodeRepositoryProvider = nodeRepositoryProvider;

    this.node = getNode();
  }

  protected Node getNode() {
    try {
      return (nodeRepositoryProvider.get().findByUuid(nodeId));
    } catch (NoResultException e) {
      return (createNode(nodeId));
    }
  }

  @Transactional
  protected Node createNode(final String nodeId) {
    return (nodeRepositoryProvider.get().persist(new Node(nodeId)));
  }

  //  @Singleton
  @Override
  public Node get() {
    //    nodeRepositoryProvider.get().refresh(node);
    return node;
  }
}
