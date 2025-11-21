import Foundation
import Apollo_Legacy
import ApolloAPI_Legacy

public final class WebSocketTransport: SubscriptionNetworkTransport {

  public enum Error: Swift.Error {
    /// WebSocketTransport has not yet been implemented for Apollo iOS 2.0. This will be implemented in a future
    /// release.
    case notImplemented
  }

  public func send<Subscription: GraphQLSubscription>(
    subscription: Subscription,
    fetchBehavior: Apollo_Legacy.FetchBehavior,
    requestConfiguration: Apollo_Legacy.RequestConfiguration
  ) throws -> AsyncThrowingStream<Apollo_Legacy.GraphQLResponse<Subscription>, any Swift.Error> {
    throw Error.notImplemented
  }

}
