export interface DateProvider {
  now(): Date;
  addSeconds(date: Date, seconds: number): Date;
}
