/***************************************************************************
* Copyright (c) 2013 Reza Fatahilah Shah <rshah0385@kireihana.com>
* Copyright (c) 2013 Abdurrahman AVCI <abdurrahmanavci@gmail.com>
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
* OR OTHER DEALINGS IN THE SOFTWARE.
*
***************************************************************************/

// Custom theme file for SDDM
// File location: /usr/share/sddm/themes/elarun/

import QtQuick 2.0
import SddmComponents 2.0

Rectangle {
    width: 640 *2
    height: 480 *2

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        onLoginSucceeded: {
        }
        onLoginFailed: {
            pw_entry.text = ""
        }
    }

    Background {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: {
            if (status == Image.Error && source != config.defaultBackground) {
                source = config.defaultBackground
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        //visible: primaryScreen

        Rectangle {
            width: 416 *2; height: 262 *2
            color: "#00000000"

            anchors.centerIn: parent

            Image {
                anchors.fill: parent
                source: "images/rectangle.png"
            }

            Image {
                anchors.fill: parent
                source: "images/rectangle_overlay.png"
                opacity: 0.1
            }

            Item {
                anchors.margins: 20 *2
                anchors.fill: parent

                Text {
                    height: 50 *2
                    anchors.top: parent.top
                    anchors.left: parent.left; anchors.right: parent.right

                    color: "#333333"
                    // color: "#0b678c"
                    // opacity: 0.75

                    text: "Login" // sddm.hostName

                    font.bold: true
                    font.pixelSize: 18 *3
                }

                Column {
                    anchors.centerIn: parent

                    Row {
                        Image {
                            source: "images/user_icon.png"
                            width: 60; height: 60
                            anchors.verticalCenter: parent.verticalCenter;
                            anchors.verticalCenterOffset: -height/8
                        }

                        TextBox {
                            id: user_entry

                            width: 150 *2; height: 30 *2
                            anchors.verticalCenter: parent.verticalCenter;
                            anchors.verticalCenterOffset: -height/8

                            text: userModel.lastUser

                            font.pixelSize: 14 *3

                            KeyNavigation.backtab: layoutBox; KeyNavigation.tab: pw_entry
                        }
                    }

                    Row {

                        Image {
                            source: "images/lock.png"
                            width: 60; height: 60
                            anchors.verticalCenter: parent.verticalCenter;
                            anchors.verticalCenterOffset: height/8
                        }

                        PasswordBox {
                            id: pw_entry
                            width: 150 *2; height: 30 *2
                            anchors.verticalCenter: parent.verticalCenter;
                            anchors.verticalCenterOffset: height/8

                            tooltipBG: "CornflowerBlue"

                            font.pixelSize: 14 *1.5

                            KeyNavigation.backtab: user_entry; KeyNavigation.tab: login_button

                            Keys.onPressed: {
                                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                    sddm.login(user_entry.text, pw_entry.text, sessionIndex)
                                    event.accepted = true
                                }
                            }
                        }
                    }
                }

                ImageButton {
                    id: login_button
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 20 *2

                    source: "images/login_normal.png"

                    onClicked: sddm.login(user_entry.text, pw_entry.text, sessionIndex)

                    KeyNavigation.backtab: pw_entry; KeyNavigation.tab: system_button
                }

                Item {
                    height: 20 *2
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left; anchors.right: parent.right

                    Row {
                        id: buttonRow
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter

                        spacing: 8 *2

                        ImageButton {
                            id: system_button
                            source: "images/system_shutdown.png"
                            width: 50; height: 50
                            onClicked: sddm.powerOff()

                            KeyNavigation.backtab: login_button; KeyNavigation.tab: reboot_button
                        }

                        ImageButton {
                            id: reboot_button
                            source: "images/system_reboot.png"
                            width: 50; height: 50
                            onClicked: sddm.reboot()

                            KeyNavigation.backtab: system_button; KeyNavigation.tab: suspend_button
                        }

                        ImageButton {
                            id: suspend_button
                            source: "images/system_suspend.png"
                            width: 50; height: 50
                            visible: sddm.canSuspend
                            onClicked: sddm.suspend()

                            KeyNavigation.backtab: reboot_button; KeyNavigation.tab: hibernate_button
                        }

                        ImageButton {
                            id: hibernate_button
                            source: "images/system_hibernate.png"
                            width: 50; height: 50
                            visible: sddm.canHibernate
                            onClicked: sddm.hibernate()

                            KeyNavigation.backtab: suspend_button; KeyNavigation.tab: session
                        }
                    }

                    Timer {
                        id: time
                        interval: 100
                        running: true
                        repeat: true

                        onTriggered: {
                            //dateTime.text = Qt.formatDateTime(new Date(), "dddd, dd MMMM yyyy HH:mm AP")
                            dateTime.text = Qt.formatDateTime(new Date(), "HH:mm  ddd, MMM dd, yyyy")
                        }
                    }

                    Text {
                        id: dateTime
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        horizontalAlignment: Text.AlignRight

                        //color: "#0b678c"
                        color: "#333333"
                        font.bold: true
                        font.pixelSize: 12 *3
                    }
                }
            }
        }
    }

    Rectangle {
        id: actionBar
        anchors.top: parent.top;
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width; height: 40
        color: "#ffffff"
        opacity: 0.7

        Row {
            anchors.left: parent.left
            anchors.margins: 5
            height: parent.height
            spacing: 5 *2

            Text {
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter

                text: textConstants.session
                font.pixelSize: 14 *2
                verticalAlignment: Text.AlignVCenter
            }

            ComboBox {
                id: session
                width: 245 *0.7
                anchors.verticalCenter: parent.verticalCenter

                arrowIcon: "angle-down.png"

                model: sessionModel
                index: sessionModel.lastIndex

                font.pixelSize: 14 *1.5

                KeyNavigation.backtab: hibernate_button; KeyNavigation.tab: layoutBox
            }

            Text {
                height: parent.height
                anchors.verticalCenter: parent.verticalCenter

                text: textConstants.layout
                font.pixelSize: 14 *2
                verticalAlignment: Text.AlignVCenter
            }

            LayoutBox {
                id: layoutBox
                width: 90 *1
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 14 *1.5

                arrowIcon: "angle-down.png"

                KeyNavigation.backtab: session; KeyNavigation.tab: user_entry
            }
        }
    }

    Component.onCompleted: {
        if (user_entry.text === "")
            user_entry.focus = true
        else
            pw_entry.focus = true
    }
}
