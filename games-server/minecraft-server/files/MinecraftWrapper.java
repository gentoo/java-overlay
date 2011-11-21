package org.gentoo.java.minecraft;
import net.minecraft.server.MinecraftServer;

public class MinecraftWrapper {
	private static MinecraftServer server = new MinecraftServer();

	public static void main(String args[]) {
		Runtime.getRuntime().addShutdownHook(new Thread() {
			public void run() {
				server.a();
			}
		});

		server.run();
	}
}
