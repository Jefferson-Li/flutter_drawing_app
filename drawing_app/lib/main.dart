import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: DrawingApp()));
}

class DrawingApp extends StatefulWidget {
  @override
  _DrawingAppState createState() => _DrawingAppState();
}

class _DrawingAppState extends State<DrawingApp> {
  List<DrawingPoint> points = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 2.0;
  Offset? oldPoint;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('簡單繪圖程式'),
      ),
      body: Column(
        children: [
          // 工具列
          Container(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final ColorPicker = await showColorPicker();
                    if (ColorPicker != null) {
                      setState(() {
                        selectedColor = ColorPicker;
                      });
                    }
                  },
                  child: Text('選擇顏色'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      points.clear();
                    });
                  },
                  child: Text('清除畫布'),
                ),
                SizedBox(width: 8),
                Text('筆刷大小:'),
                Slider(
                  value: strokeWidth,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: strokeWidth.round().toString(),
                  onChanged: (value) {
                    setState(() {
                      strokeWidth = value;
                    });
                  },
                ),
              ],
            ),
          ),
          // 畫布
          Expanded(
            child: Container(  // 添加 Container 來控制畫布大小
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: GestureDetector(
                onPanStart: (details) {
                  oldPoint = details.localPosition;
                },
                onPanUpdate: (details) {
                  setState(() {
                    points.add(DrawingPoint(
                      start: oldPoint!,
                      end: details.localPosition,
                      paint: Paint()
                        ..color = selectedColor
                        ..strokeWidth = strokeWidth
                        ..strokeCap = StrokeCap.round,
                    ));
                    oldPoint = details.localPosition;
                  });
                },
                onPanEnd: (details) {
                  oldPoint = null;
                },
                child: CustomPaint(
                  painter: DrawingPainter(points: points),
                  size: Size.infinite,  // 這行保持不變
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Color?> showColorPicker() async {
    return await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('選擇顏色'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: selectedColor,
            onColorChanged: (color) {
              setState(() {
                selectedColor = color;
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(selectedColor);
            },
            child: Text('確定'),
          ),
        ],
      ),
    );
  }
}

class DrawingPoint {
  final Offset start;
  final Offset end;
  final Paint paint;

  DrawingPoint({
    required this.start,
    required this.end,
    required this.paint,
  });
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;

  DrawingPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    for (var point in points) {
      canvas.drawLine(point.start, point.end, point.paint);
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

// 簡單的顏色選擇器組件
class ColorPicker extends StatelessWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  ColorPicker({
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 200,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        itemCount: Colors.primaries.length,
        itemBuilder: (context, index) {
          final isSelected = pickerColor == Colors.primaries[index];
          return Material(  // 添加 Material widget 來獲得水波紋效果
            color: Colors.transparent,
            child: InkWell(  // 使用 InkWell 替代 GestureDetector
              onTap: () => onColorChanged(Colors.primaries[index]),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.primaries[index],
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.grey,
                    width: isSelected ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    )
                  ] : [],
                ),
                child: isSelected ? Center(
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  ),
                ) : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
