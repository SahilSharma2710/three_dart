import 'dart:async';



import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gl/flutter_gl.dart';

import 'package:three_dart/three_dart.dart' as THREE;

class webgl_geometry_shapes extends StatefulWidget {
  String fileName;
  webgl_geometry_shapes({Key? key, required this.fileName}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<webgl_geometry_shapes> {
  late FlutterGlPlugin three3dRender;
  THREE.WebGLRenderer? renderer;

  int? fboId;
  late double width;
  late double height;

  Size? screenSize;

  late THREE.Scene scene;
  late THREE.Camera camera;
  late THREE.Mesh mesh;
  late THREE.Group group;
  late THREE.Texture texture;

  double dpr = 1.0;

  bool verbose = true;
  bool disposed = false;

  late THREE.WebGLRenderTarget renderTarget;

  dynamic? sourceTexture;

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    width = screenSize!.width;
    height = screenSize!.height;

    three3dRender = FlutterGlPlugin();

    Map<String, dynamic> _options = {
      "antialias": true,
      "alpha": false,
      "width": width.toInt(),
      "height": height.toInt(),
      "dpr": dpr
    };

    await three3dRender.initialize(options: _options);

    setState(() {});

    // TODO web wait dom ok!!!
    Future.delayed(const Duration(milliseconds: 100), () async {
      await three3dRender.prepareContext();

      initScene();
    });
  }

  initSize(BuildContext context) {
    if (screenSize != null) {
      return;
    }

    final mqd = MediaQuery.of(context);

    screenSize = mqd.size;
    dpr = mqd.devicePixelRatio;

    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
      ),
      body: Builder(
        builder: (BuildContext context) {
          initSize(context);
          return SingleChildScrollView(child: _build(context));
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Text("render"),
        onPressed: () {
          render();
        },
      ),
    );
  }

  Widget _build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Stack(
            children: [
              Container(
                  width: width,
                  height: height,
                  color: Colors.black,
                  child: Builder(builder: (BuildContext context) {
                    if (kIsWeb) {
                      return three3dRender.isInitialized
                          ? HtmlElementView(
                              viewType: three3dRender.textureId!.toString())
                          : Container();
                    } else {
                      return three3dRender.isInitialized
                          ? Texture(textureId: three3dRender.textureId!)
                          : Container();
                    }
                  })),
            ],
          ),
        ),
      ],
    );
  }

  render() {
    int _t = DateTime.now().millisecondsSinceEpoch;

    final _gl = three3dRender.gl;

    renderer!.render(scene, camera);

    int _t1 = DateTime.now().millisecondsSinceEpoch;

    if (verbose) {
      print("render cost: ${_t1 - _t} ");
      print(renderer!.info.memory);
      print(renderer!.info.render);
    }

    // 重要 更新纹理之前一定要调用 确保gl程序执行完毕
    _gl.flush();

    if (verbose) print(" render: sourceTexture: $sourceTexture ");

    if (!kIsWeb) {
      three3dRender.updateTexture(sourceTexture);
    }
  }

  initRenderer() {
    Map<String, dynamic> _options = {
      "width": width,
      "height": height,
      "gl": three3dRender.gl,
      "antialias": true,
      "canvas": three3dRender.element
    };
    renderer = THREE.WebGLRenderer(_options);
    renderer!.setPixelRatio(dpr);
    renderer!.setSize(width, height, false);
    renderer!.shadowMap.enabled = false;

    if (!kIsWeb) {
      var pars = THREE.WebGLRenderTargetOptions({
        "minFilter": THREE.LinearFilter,
        "magFilter": THREE.LinearFilter,
        "format": THREE.RGBAFormat
      });
      renderTarget = THREE.WebGLMultisampleRenderTarget(
          (width * dpr).toInt(), (height * dpr).toInt(), pars);
      renderer!.setRenderTarget(renderTarget);
      sourceTexture = renderer!.getRenderTargetGLTexture(renderTarget);
    }
  }

  initScene() {
    initRenderer();
    initPage();
  }

  initPage() async {
    scene = THREE.Scene();

    camera = THREE.PerspectiveCamera(50, width / height, 1, 2000);
    // let camra far
    camera.position.set(0, 150, 1500);
    scene.add(camera);

    var light = THREE.PointLight(0xffffff, 0.8);
    camera.add(light);

    group = THREE.Group();
    group.position.y = 50;
    scene.add(group);

    var loader = THREE.TextureLoader(null);
    texture =
        await loader.loadAsync("assets/textures/uv_grid_opengl.jpg", null);

    // it's necessary to apply these settings in order to correctly display the texture on a shape geometry

    texture.wrapS = texture.wrapT = THREE.RepeatWrapping;
    texture.repeat.set(0.008, 0.008);

    // California

    var californiaPts = [];

    californiaPts.add(THREE.Vector2(610, 320));
    californiaPts.add(THREE.Vector2(450, 300));
    californiaPts.add(THREE.Vector2(392, 392));
    californiaPts.add(THREE.Vector2(266, 438));
    californiaPts.add(THREE.Vector2(190, 570));
    californiaPts.add(THREE.Vector2(190, 600));
    californiaPts.add(THREE.Vector2(160, 620));
    californiaPts.add(THREE.Vector2(160, 650));
    californiaPts.add(THREE.Vector2(180, 640));
    californiaPts.add(THREE.Vector2(165, 680));
    californiaPts.add(THREE.Vector2(150, 670));
    californiaPts.add(THREE.Vector2(90, 737));
    californiaPts.add(THREE.Vector2(80, 795));
    californiaPts.add(THREE.Vector2(50, 835));
    californiaPts.add(THREE.Vector2(64, 870));
    californiaPts.add(THREE.Vector2(60, 945));
    californiaPts.add(THREE.Vector2(300, 945));
    californiaPts.add(THREE.Vector2(300, 743));
    californiaPts.add(THREE.Vector2(600, 473));
    californiaPts.add(THREE.Vector2(626, 425));
    californiaPts.add(THREE.Vector2(600, 370));
    californiaPts.add(THREE.Vector2(610, 320));

    for (var i = 0; i < californiaPts.length; i++) {
      californiaPts[i].multiplyScalar(0.25);
    }

    var californiaShape = THREE.Shape(californiaPts);

    // Triangle

    var triangleShape = THREE.Shape(null)
        .moveTo(80.0, 20.0)
        .lineTo(40.0, 80.0)
        .lineTo(120.0, 80.0)
        .lineTo(80.0, 20.0); // close path

    // Heart

    double x = 0, y = 0;

    var heartShape =
        THREE.Shape(null) // From http://blog.burlock.org/html5/130-paths
            .moveTo(x + 25, y + 25)
            .bezierCurveTo(x + 25, y + 25, x + 20, y, x, y)
            .bezierCurveTo(x - 30, y, x - 30, y + 35, x - 30, y + 35)
            .bezierCurveTo(x - 30, y + 55, x - 10, y + 77, x + 25, y + 95)
            .bezierCurveTo(x + 60, y + 77, x + 80, y + 55, x + 80, y + 35)
            .bezierCurveTo(x + 80, y + 35, x + 80, y, x + 50, y)
            .bezierCurveTo(x + 35, y, x + 25, y + 25, x + 25, y + 25);

    // Square

    double sqLength = 80;

    var squareShape = THREE.Shape(null)
        .moveTo(0.0, 0.0)
        .lineTo(0.0, sqLength)
        .lineTo(sqLength, sqLength)
        .lineTo(sqLength, 0.0)
        .lineTo(0.0, 0.0);

    // Rounded rectangle

    var roundedRectShape = THREE.Shape(null);

    roundedRect(ctx, num x, num y, num width, num height, num radius) {
      ctx.moveTo(x, y + radius);
      ctx.lineTo(x, y + height - radius);
      ctx.quadraticCurveTo(x, y + height, x + radius, y + height);
      ctx.lineTo(x + width - radius, y + height);
      ctx.quadraticCurveTo(
          x + width, y + height, x + width, y + height - radius);
      ctx.lineTo(x + width, y + radius);
      ctx.quadraticCurveTo(x + width, y, x + width - radius, y);
      ctx.lineTo(x + radius, y);
      ctx.quadraticCurveTo(x, y, x, y + radius);
    }
    roundedRect(roundedRectShape, 0, 0, 50, 50, 20);

    // Track

    var trackShape = THREE.Shape(null)
        .moveTo(40.0, 40.0)
        .lineTo(40.0, 160.0)
        .absarc(60.0, 160.0, 20.0, THREE.Math.PI, 0.0, true)
        .lineTo(80, 40)
        .absarc(60, 40, 20, 2 * THREE.Math.PI, THREE.Math.PI, true);

    // Circle

    double circleRadius = 40;
    var circleShape = THREE.Shape(null)
        .moveTo(0, circleRadius)
        .quadraticCurveTo(circleRadius, circleRadius, circleRadius, 0)
        .quadraticCurveTo(circleRadius, -circleRadius, 0, -circleRadius)
        .quadraticCurveTo(-circleRadius, -circleRadius, -circleRadius, 0)
        .quadraticCurveTo(-circleRadius, circleRadius, 0, circleRadius);

    // Fish

    var fishShape = THREE.Shape(null)
        .moveTo(x, y)
        .quadraticCurveTo(x + 50, y - 80, x + 90, y - 10)
        .quadraticCurveTo(x + 100, y - 10, x + 115, y - 40)
        .quadraticCurveTo(x + 115, y, x + 115, y + 40)
        .quadraticCurveTo(x + 100, y + 10, x + 90, y + 10)
        .quadraticCurveTo(x + 50, y + 80, x, y);

    // Arc circle

    var arcShape = THREE.Shape(null)
        .moveTo(50, 10)
        .absarc(10, 10, 40, 0, THREE.Math.PI * 2, false);

    var holePath = THREE.Path(null)
        .moveTo(20, 10)
        .absarc(10, 10, 10, 0, THREE.Math.PI * 2, true);

    arcShape.holes.add(holePath);

    // Smiley

    var smileyShape = THREE.Shape(null)
        .moveTo(80, 40)
        .absarc(40, 40, 40, 0, THREE.Math.PI * 2, false);

    var smileyEye1Path = THREE.Path(null)
        .moveTo(35, 20)
        .absellipse(25, 20, 10, 10, 0, THREE.Math.PI * 2, true, null);

    var smileyEye2Path = THREE.Path(null)
        .moveTo(65, 20)
        .absarc(55, 20, 10, 0, THREE.Math.PI * 2, true);

    var smileyMouthPath = THREE.Path(null)
        .moveTo(20, 40)
        .quadraticCurveTo(40, 60, 60, 40)
        .bezierCurveTo(70, 45, 70, 50, 60, 60)
        .quadraticCurveTo(40, 80, 20, 60)
        .quadraticCurveTo(5, 50, 20, 40);

    smileyShape.holes.add(smileyEye1Path);
    smileyShape.holes.add(smileyEye2Path);
    smileyShape.holes.add(smileyMouthPath);

    // Spline shape

    List<THREE.Vector2> splinepts = [];
    splinepts.add(THREE.Vector2(70, 20));
    splinepts.add(THREE.Vector2(80, 90));
    splinepts.add(THREE.Vector2(-30, 70));
    splinepts.add(THREE.Vector2(0, 0));

    var splineShape = THREE.Shape(null).moveTo(0, 0).splineThru(splinepts);

    var extrudeSettings = {
      "depth": 8,
      "bevelEnabled": true,
      "bevelSegments": 2,
      "steps": 2,
      "bevelSize": 1,
      "bevelThickness": 1
    };

    // addShape( shape, color, x, y, z, rx, ry,rz, s );

    addShape(
        californiaShape, extrudeSettings, 0xf08000, -300, -100, 0, 0, 0, 0, 1);
    addShape(triangleShape, extrudeSettings, 0x8080f0, -180, 0, 0, 0, 0, 0, 1);
    addShape(
        roundedRectShape, extrudeSettings, 0x008000, -150, 150, 0, 0, 0, 0, 1);
    addShape(trackShape, extrudeSettings, 0x008080, 200, -100, 0, 0, 0, 0, 1);
    addShape(squareShape, extrudeSettings, 0x0040f0, 150, 100, 0, 0, 0, 0, 1);
    addShape(heartShape, extrudeSettings, 0xf00000, 60, 100, 0, 0, 0,
        THREE.Math.PI, 1);
    addShape(circleShape, extrudeSettings, 0x00f000, 120, 250, 0, 0, 0, 0, 1);
    addShape(fishShape, extrudeSettings, 0x404040, -60, 200, 0, 0, 0, 0, 1);
    addShape(smileyShape, extrudeSettings, 0xf000f0, -200, 250, 0, 0, 0,
        THREE.Math.PI, 1);
    addShape(arcShape, extrudeSettings, 0x804000, 150, 0, 0, 0, 0, 0, 1);
    addShape(splineShape, extrudeSettings, 0x808080, -50, -100, 0, 0, 0, 0, 1);

    addLineShape(arcShape.holes[0], 0x804000, 150, 0, 0, 0, 0, 0, 1);

    for (var i = 0; i < smileyShape.holes.length; i += 1) {
      addLineShape(
          smileyShape.holes[i], 0xf000f0, -200, 250, 0, 0, 0, THREE.Math.PI, 1);
    }

    //

    animate();
  }

  addShape(shape, extrudeSettings, color, double x, double y, double z, double rx, double ry, double rz, double s) {
    // flat shape with texture
    // note: default UVs generated by THREE.ShapeGeometry are simply the x- and y-coordinates of the vertices

    var geometry = THREE.ShapeGeometry(shape);

    var mesh = THREE.Mesh(
        geometry,
        THREE.MeshPhongMaterial(
            {"side": THREE.DoubleSide, "map": texture}));
    mesh.position.set(x, y, z - 175.0);
    mesh.rotation.set(rx, ry, rz);
    mesh.scale.set(s, s, s);
    group.add(mesh);

    // flat shape

    geometry = THREE.ShapeGeometry(shape);

    mesh = THREE.Mesh(
        geometry,
        THREE.MeshPhongMaterial(
            {"color": color, "side": THREE.DoubleSide}));
    mesh.position.set(x, y, z - 125.0);
    mesh.rotation.set(rx, ry, rz);
    mesh.scale.set(s, s, s);
    group.add(mesh);

    // extruded shape

    var geometry2 = THREE.ExtrudeGeometry([shape], extrudeSettings);

    mesh = THREE.Mesh(
        geometry2, THREE.MeshPhongMaterial({"color": color}));
    mesh.position.set(x, y, z - 75.0);
    mesh.rotation.set(rx, ry, rz);
    mesh.scale.set(s, s, s);
    group.add(mesh);

    addLineShape(shape, color, x, y, z, rx, ry, rz, s);
  }

  addLineShape(shape, color, double x, double y, double z, double rx, double ry, double rz, double s) {
    // lines

    shape.autoClose = true;

    var points = shape.getPoints();
    var spacedPoints = shape.getSpacedPoints(50);

    var geometryPoints = THREE.BufferGeometry().setFromPoints(points);
    var geometrySpacedPoints =
        THREE.BufferGeometry().setFromPoints(spacedPoints);

    // solid line

    var line = THREE.Line(
        geometryPoints, THREE.LineBasicMaterial({"color": color}));
    line.position.set(x, y, z - 25);
    line.rotation.set(rx, ry, rz);
    line.scale.set(s, s, s);
    group.add(line);

    // line from equidistance sampled points

    line = THREE.Line(
        geometrySpacedPoints, THREE.LineBasicMaterial({"color": color}));
    line.position.set(x, y, z + 25);
    line.rotation.set(rx, ry, rz);
    line.scale.set(s, s, s);
    group.add(line);

    // vertices from real points

    var particles = THREE.Points(
        geometryPoints, THREE.PointsMaterial({"color": color, "size": 4}));
    particles.position.set(x, y, z + 75);
    particles.rotation.set(rx, ry, rz);
    particles.scale.set(s, s, s);
    group.add(particles);

    // equidistance sampled points

    particles = THREE.Points(geometrySpacedPoints,
        THREE.PointsMaterial({"color": color, "size": 4}));
    particles.position.set(x, y, z + 125);
    particles.rotation.set(rx, ry, rz);
    particles.scale.set(s, s, s);
    group.add(particles);
  }

  animate() {
    if (!mounted || disposed) {
      return;
    }

    // mesh.rotation.x += 0.005;
    // mesh.rotation.z += 0.01;

    render();

    Future.delayed(const Duration(milliseconds: 40), () {
      animate();
    });
  }

  @override
  void dispose() {
    print(" dispose ............. ");
    disposed = true;
    three3dRender.dispose();

    super.dispose();
  }
}
