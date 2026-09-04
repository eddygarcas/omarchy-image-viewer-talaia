#pragma once

#include <QObject>
#include <QString>

// Reads the live Omarchy color palette so the QML side can theme itself from
// it (see qml/Theme.qml). Kept separate from ImageBackend since it has
// nothing to do with image manipulation - it's a UI concern.
class ThemeReader : public QObject
{
    Q_OBJECT
public:
    explicit ThemeReader(QObject *parent = nullptr) : QObject(parent) {}

    // Returns the contents of ~/.local/state/omarchy/current/theme/colors.toml,
    // or an empty string if it doesn't exist (non-Omarchy systems, or Omarchy
    // without a theme applied yet) - Theme.qml falls back to its own palette then.
    Q_INVOKABLE QString omarchyColors() const;
};
