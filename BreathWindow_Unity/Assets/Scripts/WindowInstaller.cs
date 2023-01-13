using Zenject;

public class WindowInstaller : MonoInstaller
{
    public override void InstallBindings()
    {
        Container
            .Bind<IInputProvider>()
            .To<TestInputProvider>()
            .AsSingle();
        
        // Container
        //     .Bind<IInputProvider>()
        //     .To<QuestInputProvider>()
        //     .AsSingle();
    }
}