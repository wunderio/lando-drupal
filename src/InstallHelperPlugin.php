<?php

namespace Wunderio\LandoDrupal\Composer;

use Composer\Composer;
use Composer\EventDispatcher\EventSubscriberInterface;
use Composer\Installer\PackageEvent;
use Composer\Installer\PackageEvents;
use Composer\IO\IOInterface;
use Composer\Plugin\PluginInterface;

/**
 * Class InstallHelperPlugin.
 *
 * Help to deploy files to project root and install custom extensions.
 *
 * @package Wunderio\LandoDrupal\Composer
 */
class InstallHelperPlugin implements PluginInterface, EventSubscriberInterface {

  /**
   * Name of this package.
   */
  private const PACKAGE_NAME = 'wunderio/lando-drupal';

  /**
   * The Composer service.
   *
   * @var \Composer\Composer
   */
  protected $composer;

  /**
   * Composer's I/O service.
   *
   * @var \Composer\IO\IOInterface
   */
  protected $io;

  /**
   * Full path to project root where composer.json is located.
   *
   * Example: /app.
   *
   * @var string
   */
  protected $projectDir;

  /**
   * Full path to the vendor directory.
   *
   * Example: /app/vendor.
   *
   * @var string
   */
  protected $vendorDir;

  /**
   * {@inheritdoc}
   */
  public function activate(Composer $composer, IOInterface $io): void {
    $this->composer = $composer;
    $this->io = $io;
    $this->projectDir = getcwd();

    $vendor_dir = $this->composer->getConfig()->get('vendor-dir');
    $this->vendorDir = realpath($vendor_dir);
  }

  /**
   * {@inheritdoc}
   */
  public static function getSubscribedEvents() {
    return [
      PackageEvents::POST_PACKAGE_INSTALL => [
        ['onWunderIoLandoDrupalPackageInstall', 0],
      ],
      PackageEvents::POST_PACKAGE_UPDATE => [
        ['onWunderIoLandoDrupalPackageInstall', 0],
      ],
    ];
  }

  /**
   * {@inheritdoc}
   */
  public function deactivate(Composer $composer, IOInterface $io) {

  }

  /**
   * {@inheritdoc}
   */
  public function uninstall(Composer $composer, IOInterface $io) {
  }

  /**
   * Install event callback called from getSubscribedEvents().
   *
   * @param \Composer\Installer\PackageEvent $event
   *   Composer package event sent on install/update/remove.
   */
  public function onWunderIoLandoDrupalPackageInstall(PackageEvent $event) {
    /** @var \Composer\DependencyResolver\Operation\InstallOperation $operation */
    $operation = $event->getOperation();

    // Composer operations have access to packages, just through different
    // methods, which depend on whether the operation is an InstallOperation or
    // an UpdateOperation
    $current_package = method_exists($operation, 'getPackage')
      ? $operation->getPackage()
      : $operation->getInitialPackage();

    $current_package_name = $current_package->getName();

    // We only want to continue for this package.
    if ($current_package_name !== self::PACKAGE_NAME) {
      return NULL;
    }

    self::deployLandoFiles();

    $output = shell_exec('bash vendor/wunderio/lando-drupal/scripts/load_extensions.sh');
    $this->io->write("<info>{$output}</info>");
  }

  /**
   * Update event callback called from getSubscribedEvents().
   *
   * @param \Composer\Installer\PackageEvent $event
   *   Composer package event sent on install/update/remove.
   */
  public function onWunderIoLandoDrupalPackageUpdate(PackageEvent $event) {
    self::deployLandoFiles();
  }

  /**
   * Copy the .lando.base.yml file and the dist/ directory contents to the project.
   */
  private function deployLandoFiles(): void {
    // Copy contents of dist folder to project.
    $distDir = "{$this->vendorDir}/" . self::PACKAGE_NAME . '/dist';
    $destDir = "{$this->projectDir}";
    self::rcopy($distDir, $destDir);
  }

  /**
   * Recursively copy files from one directory to another.
   *
   * Code is borrowed from koodimonni/composer-dropin-installer.
   *
   * @param string $src
   *   Source of files being copied.
   * @param string $dest
   *   Destination of files being copied.
   *
   * @return bool
   *   TRUE if recursive copy was successful, FALSE otherwise.
   */
  private static function rcopy($src, $dest): bool {
    // If source is not a directory stop processing.
    if (!is_dir($src)) {
      echo "Source is not a directory";
      return FALSE;
    }

    // If the destination directory does not exist create it.
    if (!is_dir($dest)) {
      if (!mkdir($dest, 0777, TRUE)) {
        // If the destination directory could not be created stop processing.
        echo "Can't create destination path: {$dest}\n";
        return FALSE;
      }
    }

    // Open the source directory to read in files.
    $i = new \DirectoryIterator($src);
    foreach ($i as $f) {
      if ($f->isFile()) {
        umask(0);
        copy($f->getRealPath(), "$dest/" . $f->getFilename());
        // Add execute permission to script file.
        if (pathinfo($f->getFilename(), PATHINFO_EXTENSION) === 'sh') {
          chmod("$dest/" . $f->getFilename(), 0755);
        }
      }
      elseif (!$f->isDot() && $f->isDir()) {
        self::rcopy($f->getRealPath(), "$dest/$f");
        // unlink($f->getRealPath());
      }
    }

    return TRUE;
    // We could Remove original directories but don't do it
    // unlink($src);
  }

  /**
   * Copy a file from one location to another.
   *
   * Code is borrowed from koodimonni/composer-dropin-installer.
   *
   * @param string $src
   *   File being copied.
   * @param string $dest
   *   Destination directory.
   *
   * @return bool
   *   TRUE if copy was successful, FALSE otherwise.
   */
  private static function copy(string $src, string $dest): bool {
    // If the destination directory does not exist create it.
    if (!is_dir($dest)) {
      if (!mkdir($dest, 0777, TRUE)) {
        // If the destination directory could not be created stop processing.
        echo "Can't create destination path: {$dest}\n";
        return FALSE;
      }
    }
    copy($src, "$dest/" . basename($src));

    return TRUE;
  }

}
