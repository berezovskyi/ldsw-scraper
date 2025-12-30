using System;
using System.Reflection;
using System.CommandLine;

public class Inspector
{
    public static void Main()
    {
        Console.WriteLine("Methods of Option<int>:");
        foreach (var m in typeof(Option<int>).GetMethods(BindingFlags.Public | BindingFlags.Instance))
        {
            Console.WriteLine(m.Name);
        }

        Console.WriteLine("\nMethods of RootCommand:");
        foreach (var m in typeof(RootCommand).GetMethods(BindingFlags.Public | BindingFlags.Instance))
        {
            Console.WriteLine(m.Name);
        }
    }
}
