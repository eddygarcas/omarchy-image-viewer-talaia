#ifndef IMGBACKEND_H
#define IMGBACKEND_H

#ifdef __cplusplus
extern "C" {
#endif

typedef void *ImgHandle;

typedef struct {
    unsigned char *data;
    int width;
    int height;
    int stride;
} ImgPixels;

/* Lifecycle */
ImgHandle img_open(const char *path);
void img_close(ImgHandle h);

/* Pixel access (returns the "display" buffer: base + live adjustments) */
ImgPixels img_get_pixels(ImgHandle h);
void img_free_pixels(unsigned char *data);

/* Cheap dimension queries (no pixel buffer allocation) */
int img_get_width(ImgHandle h);
int img_get_height(ImgHandle h);

/* Geometric transforms - each commits to history and resets adjustments */
int img_rotate90(ImgHandle h, int clockwise);
int img_flip(ImgHandle h, int horizontal);
int img_crop(ImgHandle handle, int x, int y, int w, int ch);
int img_resize(ImgHandle h, int new_w, int new_h);

/* Non-destructive color adjustment, recomputed from base on every call */
void img_adjust(ImgHandle h, float brightness, float contrast, float saturation);
/* Bakes the current display buffer into base, pushes a history entry, resets adjust params */
int img_commit_adjust(ImgHandle h);

/* History */
int img_undo(ImgHandle h);
int img_redo(ImgHandle h);
int img_reset(ImgHandle h);

/* Save (format inferred from path extension) */
int img_save(ImgHandle h, const char *path);

#ifdef __cplusplus
}
#endif

#endif /* IMGBACKEND_H */
