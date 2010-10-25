/**
 * Created by IntelliJ IDEA.
 * User: ksafonov
 * Date: 25.10.10
 * Time: 7:05
 * To change this template use File | Settings | File Templates.
 */
package {
import com.transmote.flar.marker.FLARMarkerEvent;

import examples.support.MarkerOutliner;

import mx.core.UIComponent;

public class DebugMarkerListener implements MarkerListener {
    private var _markerOutliner:MarkerOutliner;

    public function DebugMarkerListener(targetComponent:UIComponent) {
        _markerOutliner = new MarkerOutliner();
        _markerOutliner.mouseChildren = false;
        targetComponent.addChild(_markerOutliner);
    }

    public function onMarkerAdded(evt:FLARMarkerEvent):void {
        _markerOutliner.drawOutlines(evt.marker, 8, getColorByPatternId(evt.marker.patternId));
    }

    public function onMarkerUpdated(evt:FLARMarkerEvent):void {
        if (evt.marker.corners) {
            _markerOutliner.drawOutlines(evt.marker, 8, getColorByPatternId(evt.marker.patternId));
        }
    }

    public function onMarkerRemoved(evt:FLARMarkerEvent):void {
        _markerOutliner.drawOutlines(evt.marker, 4, DebugMarkerListener.getColorByPatternId(evt.marker.patternId));
    }

    private static function getColorByPatternId(patternId:int):Number {
        switch (patternId % 12) {
            case 0:
                return 0xFF1919;
            case 1:
                return 0xFF19E8;
            case 2:
                return 0x9E19FF;
            case 3:
                return 0x192EFF;
            case 4:
                return 0x1996FF;
            case 5:
                return 0x19FDFF;
            case 6:
                return 0x19FF5A;
            case 7:
                return 0x19FFAA;
            case 8:
                return 0x6CFF19;
            case 9:
                return 0xF9FF19;
            case 10:
                return 0xFFCE19;
            case 11:
                return 0xFF9A19;
            case 12:
                return 0xFF6119;
            default:
                return 0xCCCCCC;
        }
    }
}
}
