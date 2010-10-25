/**
 * Created by IntelliJ IDEA.
 * User: ksafonov
 * Date: 25.10.10
 * Time: 16:51
 * To change this template use File | Settings | File Templates.
 */
package {
import com.transmote.flar.FLARManager;
import com.transmote.flar.marker.FLARMarkerEvent;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.GradientType;
import flash.display.IBitmapDrawable;
import flash.display.Loader;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.setTimeout;

import mx.core.SoundAsset;
import mx.core.UIComponent;
import mx.formatters.DateFormatter;
import mx.graphics.ImageSnapshot;
import mx.graphics.codec.PNGEncoder;

import org.jetbrains.FaceAndMarkerDetector;

public class PhotoMaker implements MarkerListener {

    private static const CHECK_TRIGGER:Boolean = true;

    private static const PHOTO_DELAY:int = 1 * 1000; // ms
    private static const PHOTO_SHOW_DELAY:Number = 5 * 1000; // ms
    private static const FACE_DECAY:Number = 0.2;

    [Embed('/focus.mp3')]
    private static var _focusSound:Class;
    private static var _focusSoundAsset:SoundAsset = new _focusSound() as SoundAsset;
    [Embed('/shutter.mp3')]
    private static var _shutterSound:Class;
    private static var _shutterSoundAsset:SoundAsset = new _shutterSound() as SoundAsset;


    private var _faceBounds:Rectangle;

    private var _triggerDetected:Boolean;

    private var _faceAppearedAt:Date;
    private var _deaf:Boolean;
    private var _flarManager:FLARManager;
    private var _targetComponent:UIComponent;

    public function PhotoMaker(flarManager:FLARManager, targetComponent:UIComponent) {
        _flarManager = flarManager;
        _targetComponent = targetComponent;
    }

    public function onMarkerAdded(evt:FLARMarkerEvent):void {
        if (evt.marker.patternId == FaceAndMarkerDetector.FACE_MARKER_ID) {
            faceMarkerUpdatedOrMoved(evt);
        } else {
            _triggerDetected = true;
        }
        checkPhoto();
    }

    public function onMarkerUpdated(evt:FLARMarkerEvent):void {
        if (evt.marker.patternId == FaceAndMarkerDetector.FACE_MARKER_ID) {
            faceMarkerUpdatedOrMoved(evt);
        }

        checkPhoto();

    }

    public function onMarkerRemoved(evt:FLARMarkerEvent):void {
        if (_deaf) return;
        if (evt.marker.patternId == FaceAndMarkerDetector.FACE_MARKER_ID) {
            setMask(null);
            _faceAppearedAt = null;
        } else {
            _triggerDetected = false;
        }
    }

    private function setMask(corners:Vector.<Point>):void {
        _faceBounds = FaceHighlighter.getFaceRect(corners);
    }


    private function faceMarkerUpdatedOrMoved(evt:FLARMarkerEvent):void {
        setMask(evt.marker.corners);
        if (!_faceAppearedAt) {
            _faceAppearedAt = new Date();
            _focusSoundAsset.play(0);
        }
    }

    private function checkPhoto():void {
        if (_faceAppearedAt == null || (CHECK_TRIGGER && !_triggerDetected)) {
            return;
        }
        if (new Date().getTime() - _faceAppearedAt.getTime() < PHOTO_DELAY) {
            return;
        }

        _deaf = true;
        _flarManager.deactivate();
        _deaf = false;
        _shutterSoundAsset.play(0);
        loadPhotoBackground();
        _faceAppearedAt = null;
        _triggerDetected = false;
    }

    private function loadPhotoBackground():void {
        var _loader:Loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, makePhoto);
        _loader.load(new URLRequest("flex_team.jpg"));
    }

    private function makePhoto(event:Event):void {
        var photo:Bitmap = event.currentTarget.content;

        var currentImage:Sprite = Sprite(_flarManager.flarSource);
        saveImage(currentImage, "original");

        var tmpImage:Bitmap = new Bitmap();
        tmpImage.bitmapData = new BitmapData(currentImage.width, currentImage.height);
        tmpImage.bitmapData.draw(currentImage);

        var holder:Sprite = new Sprite();
        holder.addChild(tmpImage);

        var mask:Shape = new Shape();
        var mat:Matrix = new Matrix();
        var colors:Array = [0xFFFFFF,0xFFFFFF];
        var alphas:Array = [1,0];
        var ratios:Array = [255 * (1 - FACE_DECAY),255];
        mat.createGradientBox(_faceBounds.width, _faceBounds.height, 0, 0);
        mat.translate(_faceBounds.x, _faceBounds.y);
        mask.graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, mat);
        mask.graphics.drawRect(0, 0, currentImage.width, currentImage.height);
        mask.graphics.endFill();

        mask.cacheAsBitmap = true;
        holder.cacheAsBitmap = true;
        holder.addChild(mask);
        holder.mask = mask;

        var m:Matrix = new Matrix();
//            var backgroundRect:Rectangle = new Rectangle(238, 42, 75, 100);
        var backgroundRect:Rectangle = new Rectangle(225, 12, 104, 128);

        var scaleX:Number = backgroundRect.width / _faceBounds.width;
        var scaleY:Number = backgroundRect.height / _faceBounds.height;
        m.scale(scaleX, scaleY);
        m.translate(backgroundRect.x - _faceBounds.x * scaleX, backgroundRect.y - _faceBounds.y * scaleY);
        photo.bitmapData.draw(holder, m);

        var imageFile:File = saveImage(photo, "inspired");
        uploadFile(imageFile);

        Sprite(_flarManager.flarSource).visible = false;
        _targetComponent.addChild(photo);

        setTimeout(function():void {
            _targetComponent.removeChild(photo);
            Sprite(_flarManager.flarSource).visible = true;
            _flarManager.activate();
        }, PHOTO_SHOW_DELAY);
    }

    private static function saveImage(content:IBitmapDrawable, type:String):File {
        var originalSnapshot:ImageSnapshot = ImageSnapshot.captureImage(content, 0, new PNGEncoder());
        var dateFormatter:DateFormatter = new DateFormatter();
        dateFormatter.formatString = "MMM DD HH-NN-SS";
        var fileName:String = dateFormatter.format(new Date()) + "(" + type + ").png";
        var fileStream:FileStream = new FileStream();
        var file:File = new File("c:\\PhotoSet\\" + fileName);
        fileStream.open(file, FileMode.WRITE);
        fileStream.writeBytes(originalSnapshot.data, 0);
        fileStream.close();
        return file;
    }

    private function uploadFile(file:File):void {
        var urlVars:URLVariables = new URLVariables();
        urlVars.username = "";
        urlVars.password = "";

        var urlRequest:URLRequest = new URLRequest("http://twitpic.com/api/upload");
        urlRequest.method = URLRequestMethod.POST;
        urlRequest.data = urlVars;
        file.upload(urlRequest, 'media');
    }

}
}
