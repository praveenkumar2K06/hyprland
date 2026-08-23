pragma Singleton
import QtQuick

Item {
    id: root
    
    <* for name, value in colors *>
		readonly property color {{name}}: "{{value.default.hex}}"
	<* endfor *>
}
