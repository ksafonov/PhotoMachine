/**
 * Created by IntelliJ IDEA.
 * User: ksafonov
 * Date: 25.10.10
 * Time: 3:31
 * To change this template use File | Settings | File Templates.
 */
package {
import com.transmote.flar.marker.FLARMarkerEvent;

import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.UIComponent;

import org.jetbrains.FaceAndMarkerDetector;

public class FaceHighlighter implements MarkerListener {
    private static const FACE_STRETCH_X:Number = 1.2;
    private static const FACE_STRETCH_Y:Number = 1.4;

    private var _targetComponent:UIComponent;
    private var _cover:Sprite;
    private var _mask:Sprite;

    public function FaceHighlighter(targetComponent:UIComponent) {
        _targetComponent = targetComponent;

        _mask = new Sprite();
        _cover = new Sprite();
        _cover.mask = _mask;
        _targetComponent.addChild(_cover);
    }

    public function onMarkerAdded(evt:FLARMarkerEvent):void {
        if (evt.marker.patternId != FaceAndMarkerDetector.FACE_MARKER_ID) return;
        updateMask(evt.marker.corners);
    }

    public function onMarkerUpdated(evt:FLARMarkerEvent):void {
        if (evt.marker.patternId != FaceAndMarkerDetector.FACE_MARKER_ID) return;
        updateMask(evt.marker.corners);
    }

    public function onMarkerRemoved(evt:FLARMarkerEvent):void {
        if (evt.marker.patternId != FaceAndMarkerDetector.FACE_MARKER_ID) return;
        updateMask(null);
    }

    private function updateMask(corners:Vector.<Point>):void {
        _cover.visible = corners != null;

        if (corners) {
            _cover.graphics.clear();
            _cover.graphics.beginFill(0xFFFFFF, 0.5);
            _cover.graphics.drawRect(0, 0, _targetComponent.stage.stageWidth, _targetComponent.stage.stageHeight);

            _mask.graphics.clear();
            _mask.graphics.beginFill(0xFFFFFF);
            _mask.graphics.drawRect(0, 0, _targetComponent.stage.stageWidth, _targetComponent.stage.stageHeight);
            _mask.graphics.beginFill(0);
            var faceRect:Rectangle = getFaceRect(corners);
            _mask.graphics.drawEllipse(faceRect.x, faceRect.y, faceRect.width, faceRect.height);
        }
    }

    public static function getFaceRect(corners:Vector.<Point>):Rectangle {
        if (!corners) return null;

        var faceWidth:Number = corners[1].x - corners[3].x;
        var faceHeight:Number = corners[1].y - corners[3].y;
        var x:Number = corners[3].x - faceWidth * (FACE_STRETCH_X - 1) / 2;
        var y:Number = corners[3].y - faceHeight * (FACE_STRETCH_Y - 1) / 2;
        var width:Number = faceWidth * FACE_STRETCH_X;
        var height:Number = faceHeight * FACE_STRETCH_Y;
        return new Rectangle(x, y, width, height);
    }
}
}
