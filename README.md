#USE
use like 
<pre><code>    
[JImagePickerManager chooseImageFromViewController:self allowEditting:YES imageMaxSizeLength:320 completionHandle:^ (UIImage *  image,  NSDictionary *  pickingMediainfo, BOOL *  dismiss){
        imageView.image = image;
}];</code></pre>