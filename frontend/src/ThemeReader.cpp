#include "ThemeReader.h"

#include <QDir>
#include <QFile>
#include <QTextStream>

QString ThemeReader::omarchyColors() const
{
    QFile file(QDir::homePath() + "/.local/state/omarchy/current/theme/colors.toml");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return QString();

    QTextStream stream(&file);
    return stream.readAll();
}
