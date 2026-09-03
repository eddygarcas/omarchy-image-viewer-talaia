#include "ImageBackend.h"

#include <QFileInfo>
#include <QUrl>

namespace {
/// FileDialog hands QML `url` values (file:///...); plain paths (from
/// FolderModel navigation) pass through unchanged.
QString toLocalPath(const QString &path)
{
    const QUrl url(path);
    return url.isLocalFile() ? url.toLocalFile() : path;
}
}

ImageBackend::ImageBackend(QObject *parent)
    : QObject(parent), m_folderModel(new FolderModel(this))
{
}

ImageBackend::~ImageBackend()
{
    closeCurrent();
}

void ImageBackend::closeCurrent()
{
    if (m_handle) {
        img_close(m_handle);
        m_handle = nullptr;
    }
}

void ImageBackend::refreshDimensions()
{
    if (!m_handle) {
        m_width = 0;
        m_height = 0;
        return;
    }
    m_width = img_get_width(m_handle);
    m_height = img_get_height(m_handle);
}

void ImageBackend::bump()
{
    refreshDimensions();
    ++m_generation;
    emit imageChanged();
}

QImage ImageBackend::currentQImage() const
{
    if (!m_handle)
        return {};
    ImgPixels px = img_get_pixels(m_handle);
    if (!px.data || px.width <= 0 || px.height <= 0)
        return {};
    return QImage(
        px.data, px.width, px.height, px.stride, QImage::Format_RGBA8888,
        [](void *info) { img_free_pixels(static_cast<unsigned char *>(info)); },
        px.data);
}

bool ImageBackend::openImage(const QString &pathOrUrl)
{
    const QString path = toLocalPath(pathOrUrl);
    ImgHandle newHandle = img_open(path.toUtf8().constData());
    if (!newHandle) {
        emit errorOccurred(tr("Could not open image: %1").arg(path));
        return false;
    }
    closeCurrent();
    m_handle = newHandle;
    m_currentPath = path;

    const QFileInfo info(path);
    m_folderModel->setDirectory(info.absolutePath(), info.absoluteFilePath());

    bump();
    return true;
}

void ImageBackend::rotate(bool clockwise)
{
    if (!m_handle)
        return;
    if (img_rotate90(m_handle, clockwise ? 1 : 0))
        bump();
}

void ImageBackend::flip(bool horizontal)
{
    if (!m_handle)
        return;
    if (img_flip(m_handle, horizontal ? 1 : 0))
        bump();
}

void ImageBackend::crop(int x, int y, int w, int h)
{
    if (!m_handle)
        return;
    if (img_crop(m_handle, x, y, w, h))
        bump();
    else
        emit errorOccurred(tr("Invalid crop region"));
}

void ImageBackend::resizeImage(int w, int h)
{
    if (!m_handle)
        return;
    if (img_resize(m_handle, w, h))
        bump();
    else
        emit errorOccurred(tr("Invalid resize dimensions"));
}

void ImageBackend::adjust(qreal brightness, qreal contrast, qreal saturation)
{
    if (!m_handle)
        return;
    img_adjust(m_handle, static_cast<float>(brightness), static_cast<float>(contrast), static_cast<float>(saturation));
    bump();
}

void ImageBackend::commitAdjust()
{
    if (!m_handle)
        return;
    if (img_commit_adjust(m_handle))
        bump();
}

void ImageBackend::undo()
{
    if (!m_handle)
        return;
    if (img_undo(m_handle))
        bump();
}

void ImageBackend::redo()
{
    if (!m_handle)
        return;
    if (img_redo(m_handle))
        bump();
}

void ImageBackend::resetImage()
{
    if (!m_handle)
        return;
    if (img_reset(m_handle))
        bump();
}

bool ImageBackend::saveImage(const QString &pathOrUrl)
{
    if (!m_handle)
        return false;
    const QString path = toLocalPath(pathOrUrl);
    if (!img_save(m_handle, path.toUtf8().constData())) {
        emit errorOccurred(tr("Could not save image: %1").arg(path));
        return false;
    }
    return true;
}
