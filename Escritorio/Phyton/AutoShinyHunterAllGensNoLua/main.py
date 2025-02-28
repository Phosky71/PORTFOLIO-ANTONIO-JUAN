import sys

import win32con
import win32gui
from PySide6.QtCore import QProcess
from PySide6.QtWidgets import QApplication, QMainWindow, QFileDialog, QPushButton, QVBoxLayout, QWidget, QLabel, \
    QComboBox, QMessageBox


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Emulator Launcher")
        self.setGeometry(100, 100, 800, 600)

        # Layout principal
        layout = QVBoxLayout()

        # Selector de generación
        self.gen_label = QLabel("Seleccionar Generación:")
        self.gen_combo = QComboBox()
        for i in range(1, 10):
            self.gen_combo.addItem(f"Generación {i}")
        layout.addWidget(self.gen_label)
        layout.addWidget(self.gen_combo)

        # Selección de archivos
        self.sav_label = QLabel("No se ha seleccionado archivo SAV")
        sav_button = QPushButton("Seleccionar archivo SAV")
        sav_button.clicked.connect(self.select_sav)
        layout.addWidget(self.sav_label)
        layout.addWidget(sav_button)

        self.rom_label = QLabel("No se ha seleccionado archivo ROM")
        rom_button = QPushButton("Seleccionar archivo ROM")
        rom_button.clicked.connect(self.select_rom)
        layout.addWidget(self.rom_label)
        layout.addWidget(rom_button)

        # Botón para ejecutar el emulador
        execute_button = QPushButton("Ejecutar Emulador")
        execute_button.clicked.connect(self.run_emulator)
        layout.addWidget(execute_button)

        # Widget para la salida gráfica del emulador
        self.emulator_output = QWidget()
        self.emulator_output.setFixedSize(640, 480)
        layout.addWidget(self.emulator_output)

        container = QWidget()
        container.setLayout(layout)
        self.setCentralWidget(container)

        # Variables
        self.sav_path = None
        self.rom_path = None
        self.emulator_path = "./vbarerecording/VBA-rr-svn480+LRC4.exe"
        self.emulator_process = None
        self.emulator_hwnd = None  # Initialize emulator_hwnd here

    def select_sav(self):
        self.sav_path, _ = QFileDialog.getOpenFileName(self, "Seleccionar archivo SAV", "", "Archivos SAV (*.sav)")
        if self.sav_path:
            self.sav_label.setText(f"Archivo SAV seleccionado: {self.sav_path}")

    def select_rom(self):
        selected_gen = self.gen_combo.currentText()
        if selected_gen in ["Generación 1", "Generación 2"]:
            self.rom_path, _ = QFileDialog.getOpenFileName(self, "Seleccionar archivo ROM", "",
                                                           "Archivos ROM (*.gba *.gbc *.gb)")
        else:
            self.rom_path, _ = QFileDialog.getOpenFileName(self, "Seleccionar archivo ROM", "", "Archivos GBA (*.gba)")
        if self.rom_path:
            self.rom_label.setText(f"Archivo ROM seleccionado: {self.rom_path}")

    def run_emulator(self):
        if not (self.sav_path and self.rom_path):
            QMessageBox.critical(self, "Error", "Por favor selecciona un archivo ROM y un archivo SAV.")
            return

        try:
            # Iniciar el proceso del emulador
            self.emulator_process = QProcess(self)
            self.emulator_process.setProgram(self.emulator_path)
            self.emulator_process.setArguments([self.rom_path, self.sav_path])
            self.emulator_process.startDetached()

            # Embebido usando pywin32
            hwnd = self.find_emulator_window()
            if hwnd:
                self.embed_window(hwnd)
            else:
                QMessageBox.warning(self, "Advertencia", "No se pudo encontrar la ventana del emulador.")
        except Exception as e:
            QMessageBox.critical(self, "Error", f"Error al ejecutar el emulador: {e}")

    def find_emulator_window(self):
        """Encuentra la ventana del emulador usando pywin32"""

        def callback(hwnd, _):
            if win32gui.IsWindowVisible(hwnd) and "VisualBoyAdvance" in win32gui.GetWindowText(hwnd):
                self.emulator_hwnd = hwnd
                return False
            return True

        self.emulator_hwnd = None
        win32gui.EnumWindows(callback, None)
        return self.emulator_hwnd

    def embed_window(self, hwnd):
        """Embebe la ventana del emulador en el widget de salida"""
        window_id = self.emulator_output.winId()
        win32gui.SetParent(hwnd, window_id)
        win32gui.SetWindowLong(hwnd, win32con.GWL_STYLE, win32con.WS_VISIBLE | win32con.WS_CHILD)
        win32gui.MoveWindow(hwnd, 0, 0, self.emulator_output.width(), self.emulator_output.height(), True)


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())
