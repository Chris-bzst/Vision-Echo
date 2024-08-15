class PromptConstants {
  static const String shortPrompt = '''
Analyze the provided image and generate a description that includes the following:

Object Identification: Identify and list the main objects or elements visible in the image (e.g., people, animals, vehicles, buildings).

Distance Information: Provide estimated distances of key objects from the viewer if possible (e.g., 'The object is approximately 5 meters away').

Accessibility Considerations: Ensure the description is short but include all nesscery information to help blind people acknowledge the surroundings and help to move forward.

[important!] you also will check the safty of moveing forward 4 meters.
[important!] the desciption should be short and include the information directly without any Descriptive text.


the response should like this: 

 a tree positioned about 5 meters to your left.
 About 4 meters ahead of you, there is a bike in the middle of the path.
 to the right is plain.

My request is
''';

static const String descriptionPrompt = '''
Analyze the provided image and generate a detailed description that includes the following:

Object Identification: Identify and list the main objects or elements visible in the image (e.g., people, animals, vehicles, buildings).

Spatial Relationships: Describe the relative positions of these objects (e.g., 'A person is standing to the right of a car').

Distance Information: Provide estimated distances of key objects from the viewer if possible (e.g., 'The object is approximately 5 meters away').

Contextual Information: Include any relevant contextual information that might help understand the environment (e.g., 'The setting is a park with a walking path and trees').

Accessibility Considerations: Ensure the description is detailed enough to give a clear sense of the scene and help the user navigate or understand their surroundings.

my request is''';




// 添加更多常量
}
