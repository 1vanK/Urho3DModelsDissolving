Scene@ scene_;
Node@ cameraNode;
Material@ characterMat;
Material@ customCharacterMat;
float cameraYaw = 0.0f;
float cameraPitch = 15.0f;


void Start()
{
    CreateScene();
    CreateUI();
    SubscribeToEvent("Update", "HandleUpdate");
}


void CreateScene()
{
    scene_ = Scene();
    scene_.CreateComponent("Octree");
    
    Node@ zoneNode = scene_.CreateChild("Zone");
    Zone@ zone = zoneNode.CreateComponent("Zone");
    zone.boundingBox = BoundingBox(-1000.0f, 1000.0f);
    zone.ambientColor = Color(0.5f, 0.5f, 0.5f);
    zone.fogColor = Color(0.7f, 0.8f, 0.9f);
    zone.heightFog = true;
    zone.fogHeight = -0.4f;
    zone.fogHeightScale = 1.0f;
    zone.fogStart = 10.0f;
    zone.fogEnd = 100.0f;
    
    Node@ planeNode = scene_.CreateChild("Plane");
    planeNode.SetScale(1000.0f);
    planeNode.position = Vector3(0.0f, 0.0f, 0.0f);
    StaticModel@ planeObject = planeNode.CreateComponent("StaticModel");
    planeObject.model = cache.GetResource("Model", "Models/Plane.mdl");
    planeObject.castShadows = true;

    Node@ characterNode = scene_.CreateChild("Character");
    characterNode.position = Vector3(-2.0f, 0.0f, 0.0f);
    characterNode.rotation = Quaternion(0.0f, 90.0f, 0.0f);
    StaticModel@ characterObject = characterNode.CreateComponent("StaticModel");
    characterObject.model = cache.GetResource("Model", "Models/Character.mdl");
    Material@ material = cache.GetResource("Material", "Materials/Character.xml");
    characterMat = material.Clone(); // unique material
    characterObject.material = characterMat;
    characterObject.castShadows = true;

    Node@ customCharacterNode = scene_.CreateChild("CustomCharacter");
    customCharacterNode.position = Vector3(2.0f, 0.0f, 0.0f);
    customCharacterNode.rotation = Quaternion(0.0f, 90.0f, 0.0f);
    StaticModel@ customCharacterObject = customCharacterNode.CreateComponent("StaticModel");
    customCharacterObject.model = cache.GetResource("Model", "Models/Character.mdl");
    material = cache.GetResource("Material", "Materials/CharacterCustomDissolve.xml");
    customCharacterMat = material.Clone();
    customCharacterObject.material = customCharacterMat;
    customCharacterObject.castShadows = true;

    Node@ lightNode = scene_.CreateChild("Light");
    lightNode.direction = Vector3(1.0f, -1.0f, 1.0f);
    Light@ light = lightNode.CreateComponent("Light");
    light.lightType = LIGHT_DIRECTIONAL;
    light.color = Color(0.7f, 0.7f, 0.7f);
    light.castShadows = true;
    light.shadowBias = BiasParameters(0.0002f, 0.5f);
    light.shadowCascade = CascadeParameters(10.0f, 50.0f, 100.0f, 0.0f, 0.8f);
    
    cameraNode = scene_.CreateChild("Camera");
    Camera@ camera = cameraNode.CreateComponent("Camera");
    camera.farClip = 300.0f;
    cameraNode.position = Vector3(0.0f, 5.0f, -10.0f);
    cameraNode.rotation = Quaternion(cameraPitch, cameraYaw, 0.0f);
    
    Viewport@ viewport = Viewport(scene_, cameraNode.GetComponent("Camera"));
    renderer.viewports[0] = viewport;
}


void CreateUI()
{
    input.mouseVisible = true;

    XMLFile@ uiStyle = cache.GetResource("XMLFile", "UI/DefaultStyle.xml");
    ui.root.defaultStyle = uiStyle;

    Slider@ slider = ui.root.CreateChild("Slider");
    slider.SetStyleAuto();
    slider.SetPosition(50, 50);
    slider.SetSize(300, 20);
    slider.range = 1.0f; // 0 - 1 range
    SubscribeToEvent(slider, "SliderChanged", "HandleSliderChanged");
    slider.value = 0.25f;
    
    Text@ instructionText = ui.root.CreateChild("Text");
    instructionText.text =
        "Use WASDQE keys to move\n"
        "RMB to rotate view\n"
        "Slider to dissolve";
    instructionText.textEffect = TE_SHADOW;
    instructionText.SetFont(cache.GetResource("Font", "Fonts/Anonymous Pro.ttf"), 15);
    instructionText.textAlignment = HA_CENTER;
    instructionText.horizontalAlignment = HA_CENTER;
    instructionText.verticalAlignment = VA_CENTER;
    instructionText.SetPosition(0, ui.root.height / 4);
}


void HandleSliderChanged(StringHash eventType, VariantMap& eventData)
{
    float newValue = eventData["Value"].GetFloat();
    characterMat.shaderParameters["Dissolve"] = newValue;
    customCharacterMat.shaderParameters["Dissolve"] = newValue;
}


void HandleUpdate(StringHash eventType, VariantMap& eventData)
{
    float timeStep = eventData["TimeStep"].GetFloat();
    MoveCamera(timeStep);
}


void MoveCamera(float timeStep)
{
    input.mouseVisible = !input.mouseButtonDown[MOUSEB_RIGHT];

    const float MOVE_SPEED = 20.0f;
    const float MOUSE_SENSITIVITY = 0.1f;

    if (!input.mouseVisible)
    {
        IntVector2 mouseMove = input.mouseMove;
        cameraYaw += MOUSE_SENSITIVITY * mouseMove.x;
        cameraPitch += MOUSE_SENSITIVITY * mouseMove.y;
        cameraPitch = Clamp(cameraPitch, -90.0f, 90.0f);
        cameraNode.rotation = Quaternion(cameraPitch, cameraYaw, 0.0f);
    }

    if (input.keyDown['W'])
        cameraNode.Translate(Vector3(0.0f, 0.0f, 1.0f) * MOVE_SPEED * timeStep);
    if (input.keyDown['S'])
        cameraNode.Translate(Vector3(0.0f, 0.0f, -1.0f) * MOVE_SPEED * timeStep);
    if (input.keyDown['A'])
        cameraNode.Translate(Vector3(-1.0f, 0.0f, 0.0f) * MOVE_SPEED * timeStep);
    if (input.keyDown['D'])
        cameraNode.Translate(Vector3(1.0f, 0.0f, 0.0f) * MOVE_SPEED * timeStep);
    if (input.keyDown['Q'])
        cameraNode.Translate(Vector3(0.0f, -1.0f, 0.0f) * MOVE_SPEED * timeStep);
    if (input.keyDown['E'])
        cameraNode.Translate(Vector3(0.0f, 1.0f, 0.0f) * MOVE_SPEED * timeStep);
}
