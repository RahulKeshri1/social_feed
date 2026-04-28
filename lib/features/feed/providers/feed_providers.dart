/// Feed feature providers.
///
/// All providers are defined in [feed_controller.dart] alongside
/// the controller for co-location. This barrel file re-exports them.
library;

export '../presentation/controllers/feed_controller.dart'
    show feedControllerProvider, feedRepositoryProvider, FeedState;
