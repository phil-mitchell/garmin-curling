import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class CurlingApp extends Application.AppBase {
    //! Constructor
    private var _view as CurlingView?;

    public function initialize() {
        AppBase.initialize();
    }

    //! Handle app startup
    //! @param state Startup arguments
    public function onStart(state as Dictionary?) as Void {
    }

    //! Handle app shutdown
    //! @param state Shutdown arguments
    public function onStop(state as Dictionary?) as Void {
        var view = _view;
        _view = null;
        if (view != null) {
            view.onStop();
        }
    }

    //! Return the initial view for the app
    //! @return Array [View]
    public function getInitialView() as Array<Views or InputDelegates>? {
        _view = new $.CurlingView();
        return [_view, new $.BaseInputDelegate(_view)] as Array<Views or InputDelegates>;
    }

}
