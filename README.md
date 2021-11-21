# Robot orderer
This is an RPA process for the 'Build robot' course from Robocorp. It reads a .csv file with robot orders and makes orders in https://robotsparebinindustries.com/#/robot-order based on the input data. Output of this process is a list of receipt PDF files that contain details about each order and a picture of the ordered robot.

You can run the process in Visual Studio Code with Robocorp extensions, with Robocorp lab or if you have rcc.exe installed, with the following command:

rcc run -e devdata/env.json

During the process run, an input dialog will appear that asks for location or orders.csv file. You can use the following URL: https://robotsparebinindustries.com/orders.csv
