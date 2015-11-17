#!/bin/bash

get_cmakelists() {
	cmakelists="cmake_minimum_required(VERSION 2.6 FATAL_ERROR)\nproject($2)\n\nadd_executable($2 src/$2.cpp)\n\nFIND_PACKAGE(Qt4 REQUIRED)\nSET(QT_USE_QTNETWORK TRUE)\nSET(QT_USE_QTSQL TRUE)\nINCLUDE(\${QT_USE_FILE})\n\ntarget_link_libraries($2 $1/lib/LINUX64/libpvm3.a)\ntarget_link_libraries($2 $1/lib/LINUX64/libgpvm3.a)\ntarget_link_libraries($2 \${QT_LIBRARIES})\n\nSET(EXECUTABLE_OUTPUT_PATH $1/bin/LINUX64)"

	echo $cmakelists
}

get_default_source() {
	source="#include <pvm3.h>\n#include <stdio.h>\n\nint main(int argc, char **argv)\n{\n\treturn 0;\n}"
	
	echo $source
}

get_message_box_source() {
	source_message_box="#include <pvm3.h>\n#include <stdio.h>\n\n// Includes required for\n// displaying message boxes\n#include <string>\n#include <QApplication>\n#include <QTextEdit>\n\nint main(int argc, char **argv)\n{\n\t// Initialize message string\n\tstd::string message(\"[qtdefault] \\\xA9 Alex & Feri\\\nMessage: \");\n\n\t// Initialize messageBox and textEdit\n\tQApplication messageBox(argc, argv);\n\tQTextEdit textEdit;\n\ttextEdit.show();\n\n\t// Append to message\n\tmessage.append(\" Hello World!\\\n\");\n\n\t// Set message in textEdit and display messageBox\n\tQString string = QString::fromStdString(message);\n\ttextEdit.setText(string);\n\tmessageBox.exec();\n\n\treturn 0;\n}"

	echo $source_message_box;
}

#define craft function if destination folder exists
craft() {
	mkdir $1"/"$2
	echo "[qtdefault] Crafting application" \"$2\" "inside folder" \"$1\"".."
	echo "[qtdefault] Building structure.."
	mkdir $1"/"$2"/build"
	mkdir $1"/"$2"/src"
	touch $1"/"$2"/src/"$2".cpp"

	if [ "$3" == "-mb" ]; then
		echo "[qtdefault] Generating source with message box template."
		source_message_box=$(get_message_box_source)
		echo -e $source_message_box > $1"/"$2"/src/"$2".cpp"
	else
		echo "[qtdefault] Generating source with default template."
		source=$(get_default_source)
		echo -e $source > $1"/"$2"/src/"$2".cpp"
	fi

	touch $1"/"$2"/CMakeLists.txt"
	
	cmakelists=$(get_cmakelists "$pvm" "$2")
	echo -e $cmakelists > $1"/"$2"/CMakeLists.txt"	
	echo "[qtdefault] Done with structure."

	echo "[qtdefault] Running cmake inside \"build\" folder."
	cd $1"/"$2"/build";cmake -D CMAKE_BUILD_TYPE:STRING=Debug ..;
}

craft_new() {
	mkdir $1
	craft "$1" "$2" "$3"
}

#define check_destination function
check_destination() {
	if [ -d "$1" ]; then
		while true; do
			echo -n "[qtdefault] Can I craft inside" \"$1\" "folder? [y/n]:"
			read -p "" yn
			case $yn in
				[Yy]* ) craft "$1" "$2" "$3"; break;;
				[Nn]* ) echo "[qtdefault] Bye!"; exit;;
				* ) echo "[qtdefault] Geek"; craft "$1" "$2" "$3"; break;
			esac
		done  
	else
		echo -n "[qtdefault] Folder" \"$1\" "does not exist! Can I create it? [y/n]:"
		while true; do
			read -p "" yn
			case $yn in
				[Yy]* ) craft_new "$1" "$2" "$3"; break;;
				[Nn]* ) echo "[qtdefault] Bye!"; exit;;
				* ) echo "[qtdefault] Geek"; craft_new "$1" "$2" "$3"; break;
			esac
		done  
	fi
}

if [ "$1" == "" ]; then
	echo "[qtdefault] Usage: ./qtdefault.sh <path> <app_name> [-mb]"
else
	if [ "$2" == "" ]; then
		echo "[qtdefault] Usage: ./qtdefault.sh" $1 "<app_name> [-mb]"
	else
		pvm=$PVM_ROOT
		if [ "$pvm" == "" ]; then
			echo "[qtdefault] This script requires pvm library!" 
			exit
		fi
		check_destination "$1" "$2" "$3"
		echo "[qtdefault] Successfuly finished! Build something awesome!"
	fi  
fi
