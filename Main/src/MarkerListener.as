/**
 * Created by IntelliJ IDEA.
 * User: ksafonov
 * Date: 25.10.10
 * Time: 0:04
 * To change this template use File | Settings | File Templates.
 */
package {
import com.transmote.flar.marker.FLARMarkerEvent;

public interface MarkerListener {
    function onMarkerAdded(evt:FLARMarkerEvent):void;

    function onMarkerUpdated(evt:FLARMarkerEvent):void;

    function onMarkerRemoved(evt:FLARMarkerEvent):void;
}
}
