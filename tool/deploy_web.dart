import 'dart:io';

void main() async {
  print('🚀 Starting Web Deployment...');

  // 1. Flutter Build Web
  print('\n📦 Building Flutter Web...');
  final buildResult = await Process.run(
    'flutter',
    ['build', 'web', '--release'],
    runInShell: true,
  );

  if (buildResult.exitCode != 0) {
    print('❌ Build failed:');
    print(buildResult.stderr);
    exit(1);
  }
  print(buildResult.stdout);
  print('✅ Build successful.');

  // 2. Firebase Deploy
  print('\n🔥 Deploying to Firebase Hosting...');
  final deployResult = await Process.run(
    'firebase',
    ['deploy', '--only', 'hosting:rubikcube-timer'],
    runInShell: true,
  );

  if (deployResult.exitCode != 0) {
    print('❌ Deployment failed:');
    print(deployResult.stderr);
    exit(1);
  }
  print(deployResult.stdout);
  print('✅ Deployment successful!');
}
