import 'package:flutter/material.dart';
import 'package:payment_app/models/notes_models.dart';

class SingleNoteWidget extends StatelessWidget {
  final String? title;
  final String? body;
  final String? image;
  final NotesModel? notesModel;
  final int? color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SingleNoteWidget({
    super.key,
    this.body,
    this.color,
    required this.onLongPress,
    required this.onTap,
    this.title,
    this.image,
    this.notesModel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(
          left: 15,
          right: 15,
        ),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDataCell('category'),
            _buildDataCell(title!),
            _buildDataCell(body!),
            _buildDataCell('Image'),
            _buildDataCell('Date'),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Container(
      padding: const EdgeInsets.all(3),
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade800,
          ),
          right: BorderSide(
            color: Colors.grey.shade400,
          ),
        ),
      ),
      child: Center(
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: const TextStyle(
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

/*

DataTable(
            columns: const <DataColumn>[
              DataColumn(
                label: Text(
                  'Category\n(فئة المذكرة)',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Title\n(عنوان)',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Note",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Image\n(صورة)",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Date\n(تاريخ)",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ],
            rows: <DataRow>[
              DataRow(
                cells: <DataCell>[
                  const DataCell(
                    Text(
                      "category!",
                    ),
                  ),
                  DataCell(
                    Text(
                      title!,
                      style: const TextStyle(
                        fontSize: 20,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      body!,
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const DataCell(
                    Text(
                      "You",
                    ),
                  ),
                  const DataCell(
                    Text(
                      "data",
                    ),
                  ),
                ],
              ),
            ],
          ),

Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  title!,
                  style: const TextStyle(
                    color: Colors.black,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              body!,
              style: const TextStyle(
                color: Colors.black,
                overflow: TextOverflow.fade,
                decorationThickness: 20,
              ),
            ),
          ],
        ),


       

 */
